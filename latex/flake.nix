{
  description = "LaTeX development shell";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.nixcats.url = "github:melhindi/nixcats";
  inputs.nixcats.inputs.nixpkgs.follows = "nixpkgs";

  outputs =
    {
      nixpkgs,
      nixcats,
      ...
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];
      forAll =
        f:
        builtins.listToAttrs (
          map (system: {
            name = system;
            value = f system;
          }) systems
        );
    in
    {
      devShells = forAll (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) [ "drawio" ];
          };
          tex = pkgs.texliveSmall.withPackages (
            ps: with ps; [
              collection-latex
              collection-latexrecommended
              collection-latexextra
              acmart
              latexmk
              libertine
              newtx
              inconsolata
            ]
          );
          nixcatsNvim = (nixcats.packages.${system}.nixcatsTex or nixcats.packages.${system}.default);
          latexPackages =
            with pkgs;
            [
              latexrun
              tex
            ]
            ++ pkgs.lib.optionals pkgs.stdenv.hostPlatform.isLinux [ drawio ];
        in
        {
          default = pkgs.mkShell {
            packages = latexPackages;
            shellHook = ''echo "Latex dev shell ready"'';
          };

          nvim = pkgs.mkShell {
            packages = latexPackages ++ [ nixcatsNvim ];
            shellHook = ''echo "Latex dev shell ready"'';
          };
        }
      );
    };
}
