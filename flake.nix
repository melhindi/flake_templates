{
  description = "Personal Nix development flake templates";

  outputs =
    { self }:
    let
      withoutLock =
        name: path:
        builtins.path {
          inherit name path;
          filter = path: type: baseNameOf path != "flake.lock";
        };
    in
    {
      templates = {
        latex = {
          path = withoutLock "latex-template" ./latex;
          description = "LaTeX development shell with TeX Live tooling";
          welcomeText = ''
            # LaTeX Development Shell

            Enter the shell with:

            ```bash
            nix develop
            ```

            Use the Neovim-enabled shell with:

            ```bash
            nix develop .#nvim
            ```

            If you use `direnv`, create `.envrc` with the shell you want:

            ```bash
            echo 'use flake' > .envrc
            direnv allow
            ```
          '';
        };

        tla = {
          path = withoutLock "tla-template" ./tla;
          description = "TLA+ development shell with TLC, Community Modules, and VSCodium";
          welcomeText = ''
            # TLA+ Development Shell

            Enter the shell with:

            ```bash
            nix develop
            ```

            Launch the packaged editor with:

            ```bash
            nix run .#codium
            ```

            If you use `direnv`, create `.envrc` to load the shell automatically:

            ```bash
            echo 'use flake' > .envrc
            direnv allow
            ```
          '';
        };

        zig = {
          path = withoutLock "zig-template" ./zig;
          description = "Zig development shell with a selectable Zig/ZLS toolchain";
          welcomeText = ''
            # Zig Development Shell

            Enter the shell with:

            ```bash
            nix develop
            ```

            Or select a specific Zig/ZLS pair:

            ```bash
            nix develop .#zig_0_14
            nix develop .#zig_0_15
            nix develop .#zig_0_16
            nix develop .#zig_master
            ```

            If you use `direnv`, create `.envrc` with the shell you want:

            ```bash
            echo 'use flake .#zig_0_16' > .envrc
            direnv allow
            ```
          '';
        };

        typst = {
          path = withoutLock "typst-template" ./typst;
          description = "Typst development shell with typst and tinymist";
          welcomeText = ''
            # Typst Development Shell

            Enter the shell with:

            ```bash
            nix develop
            ```

            Use the Neovim-enabled shell with:

            ```bash
            nix develop .#nvim
            ```

            If you use `direnv`, create `.envrc` with the shell you want:

            ```bash
            echo 'use flake' > .envrc
            direnv allow
            ```
          '';
        };

        default = self.templates.latex;
      };
    };
}
