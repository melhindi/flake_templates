{
  description = "Typst development shell";

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
        "aarch64-linux"
        "aarch64-darwin"
      ];
      forAll = nixpkgs.lib.genAttrs systems;
    in
    {
      devShells = forAll (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
          nixcatsNvim = (nixcats.packages.${system}.nixcatsTypst or nixcats.packages.${system}.default);
          typstPackages = with pkgs; [
            typst
            tinymist
          ];
        in
        {
          default = pkgs.mkShell {
            packages = typstPackages;
            shellHook = ''echo "Typst dev shell ready"'';
          };
        }
        # nixcats only publishes packages for Linux systems.
        // nixpkgs.lib.optionalAttrs (nixcats.packages ? ${system}) {
          nvim = pkgs.mkShell {
            packages = typstPackages ++ [ nixcatsNvim ];
            shellHook = ''echo "Typst dev shell ready"'';
          };
        }
      );
    };
}
