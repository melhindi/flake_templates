{
  description = "Nix dev environment for TLA+ specifications";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      lib = nixpkgs.lib;
      # Keep the flake explicit about supported platforms instead of depending
      # on the current machine's architecture implicitly.
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = lib.genAttrs systems;
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          # Community Modules are published against the newer 1.8.x TLA+ tools.
          # Using the older `pkgs.tlaplus` (1.7.4 in this nixpkgs snapshot)
          # causes runtime linkage failures such as missing `KSubsetValue`.
          tlaTools = pkgs.tlaplus18;
          tlaExtensionVersion = "2026.3.120037";
          # VSCodium uses Open VSX by default. Pin the VSIX download explicitly
          # so the dev environment stays reproducible and does not rely on a
          # mutable in-editor extension install.
          tlaExtension = [
            (pkgs.vscode-utils.buildVscodeExtension {
              pname = "tlaplus-vscode-ide";
              version = tlaExtensionVersion;
              src = pkgs.fetchurl {
                url = "https://open-vsx.org/api/tlaplus/vscode-ide/${tlaExtensionVersion}/file/tlaplus.vscode-ide-${tlaExtensionVersion}.vsix";
                hash = "sha256-bOMAPtiO797JhylabA3HXT5BUx9/U2W6fkjFwULxyQs=";
              };
              vscodeExtPublisher = "tlaplus";
              vscodeExtName = "vscode-ide";
              vscodeExtUniqueId = "tlaplus.vscode-ide";
            })
          ];
          # Keep the required project extensions in a separate immutable store
          # path, then seed a writable workspace-local extensions directory from
          # it at runtime. This preserves a reproducible baseline while still
          # allowing interactive installation of personal extensions such as Vim.
          pinnedExtensions = pkgs.buildEnv {
            name = "vscode-extensions";
            paths = tlaExtension;
            pathsToLink = [ "/share/vscode/extensions" ];
          };
          # Community Modules provide extra TLA+ modules and optional Java
          # implementations used by TLC. Pin the published release so command
          # line model checking stays reproducible.
          communityModulesJar = pkgs.fetchurl {
            # The project publishes a stable "latest download" URL for the
            # bundled jar. The fixed hash keeps this flake reproducible and
            # will fail loudly once upstream publishes a newer release.
            url = "https://github.com/tlaplus/CommunityModules/releases/latest/download/CommunityModules-deps.jar";
            hash = "sha256-sHTExQe4S0qS+vuh9UPv52p7vvOgiHc2LH+cltB4tqg=";
          };
          # Extract the TLA+ module sources so the VS Code extension can find
          # them through normal module search paths instead of relying on jar
          # introspection for user-supplied libraries.
          communityModulesSources = pkgs.runCommand "community-modules-sources" {
            nativeBuildInputs = [ pkgs.unzip ];
          } ''
            mkdir -p "$out"
            unzip -qq ${communityModulesJar} "*.tla" -d "$out"
          '';
          # Provide direct CLI entrypoints for the common TLA+ tools with the
          # Community Modules jar already on the Java classpath.
          tlaplusWithCommunity = pkgs.writeShellScriptBin "tlaplus-community" ''
            export CLASSPATH="${communityModulesJar}:${tlaTools}/share/java/tla2tools.jar''${CLASSPATH:+:$CLASSPATH}"
            exec "${pkgs.jdk_headless}/bin/java" -XX:+UseParallelGC "$@"
          '';
          tlcWithCommunity = pkgs.writeShellScriptBin "tlc-community" ''
            exec "${tlaplusWithCommunity}/bin/tlaplus-community" tlc2.TLC "$@"
          '';
          sanyWithCommunity = pkgs.writeShellScriptBin "sany-community" ''
            exec "${tlaplusWithCommunity}/bin/tlaplus-community" tla2sany.SANY "$@"
          '';
        in
        {
          # Expose the standalone extension package as a debug aid. This keeps
          # it easy to update the pinned marketplace version without building
          # the full editor closure first.
          tla-vscode-extension = builtins.head tlaExtension;
          community-modules-jar = communityModulesJar;
          community-modules-sources = communityModulesSources;
          tlaplus-community = tlaplusWithCommunity;
          tlc-community = tlcWithCommunity;
          sany-community = sanyWithCommunity;

          # Launch plain VSCodium against a writable extension directory. The
          # script pre-populates that directory with symlinks to the pinned
          # project extensions, then leaves the directory writable for
          # interactive installs from inside the editor.
          codium = pkgs.writeShellScriptBin "codium" ''
            set -eu

            workspace_root=''${PWD}
            writable_root="$workspace_root/.nix-vscode"
            extensions_dir="$writable_root/extensions"
            user_data_dir="$writable_root/user-data"
            pinned_dir="${pinnedExtensions}/share/vscode/extensions"

            mkdir -p "$extensions_dir" "$user_data_dir"

            if [ -d "$pinned_dir" ]; then
              for ext in "$pinned_dir"/*; do
                [ -e "$ext" ] || continue
                target="$extensions_dir/$(basename "$ext")"
                if [ ! -e "$target" ]; then
                  ln -s "$ext" "$target"
                fi
              done
            fi

            exec "${pkgs.vscodium}/bin/codium" \
              --extensions-dir "$extensions_dir" \
              --user-data-dir "$user_data_dir" \
              "$@"
          '';
          default = self.packages.${system}.codium;
        });

      apps = forAllSystems (system: {
        default = {
          type = "app";
          program = "${self.packages.${system}.codium}/bin/codium";
        };
        codium = self.apps.${system}.default;
      });

      devShells = forAllSystems (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          tlaTools = pkgs.tlaplus18;
        in
        {
          default = pkgs.mkShell {
            # Graphviz provides the `dot` command. TLC can emit .dot files
            # itself, but rendering those state graphs into SVG/PNG requires
            # Graphviz in the shell.
            packages = [
              pkgs.jdk_headless
              tlaTools
              pkgs.graphviz
              self.packages.${system}.tlaplus-community
              self.packages.${system}.tlc-community
              self.packages.${system}.sany-community
              self.packages.${system}.codium
            ];

            # The VS Code extension and manual TLC invocations rely on a JVM.
            JAVA_HOME = pkgs.jdk_headless;

            # Expose the packaged TLA+ tools jar for scripts or direct Java
            # commands. The `tlc`, `sany`, and related wrappers are also on PATH.
            TLA2TOOLS_JAR = "${tlaTools}/share/java/tla2tools.jar";

            # Expose Community Modules for direct Java invocations. The wrapper
            # scripts above are usually more convenient than assembling the
            # classpath manually.
            COMMUNITY_MODULES_JAR = "${self.packages.${system}.community-modules-jar}";
            TLA_LIBRARY_PATH = "${self.packages.${system}.community-modules-sources}";
            TLA_TOOLS_CLASSPATH = "${tlaTools}/share/java/tla2tools.jar:${self.packages.${system}.community-modules-jar}";

            shellHook = ''
              mkdir -p .nix-tlaplus
              ln -snf "${tlaTools}/share/java/tla2tools.jar" .nix-tlaplus/tla2tools.jar
              ln -snf "${self.packages.${system}.community-modules-jar}" .nix-tlaplus/CommunityModules-deps.jar
              ln -snf "${self.packages.${system}.community-modules-sources}" .nix-tlaplus/modules
              mkdir -p .nix-vscode

              # Bootstrap a minimal workspace configuration for new projects.
              # Only create these files when they do not exist so the flake
              # does not overwrite project-specific editor settings.
              mkdir -p .vscode

              if [ ! -e .vscode/extensions.json ]; then
                cat > .vscode/extensions.json <<'EOF'
{
  "recommendations": [
    "tlaplus.vscode-ide"
  ]
}
EOF
              fi

              if [ ! -e .vscode/settings.json ]; then
                cat > .vscode/settings.json <<'EOF'
{
  "tlaplus.tlc.modelChecker.options": "-coverage 1",
  "tlaplus.moduleSearchPaths": [
    ".nix-tlaplus/modules"
  ]
}
EOF
              fi
            '';
          };
        });
    };
}
