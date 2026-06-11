{
  description = "Zig development shell";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.zig-overlay.url = "github:mitchellh/zig-overlay";
  inputs.zig-overlay.inputs.nixpkgs.follows = "nixpkgs";
  inputs.zls.url = "github:zigtools/zls";
  inputs.zls.inputs.nixpkgs.follows = "nixpkgs";

  outputs =
    {
      nixpkgs,
      zig-overlay,
      zls,
      ...
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      devShells = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
          mkZigShell =
            toolchain:
            pkgs.mkShell {
              packages = [
                toolchain.zig
                toolchain.zls
              ];

              ZIG = "${toolchain.zig}/bin/zig";
              ZLS = "${toolchain.zls}/bin/zls";

              shellHook = ''
                echo "Zig $(${toolchain.zig}/bin/zig version) with ZLS $(${toolchain.zls}/bin/zls --version)"
              '';
            };
        in
        rec {
          zig_0_14 = mkZigShell {
            zig = pkgs.zig_0_14;
            zls = pkgs.zls_0_14;
          };
          zig_0_15 = mkZigShell {
            zig = pkgs.zig_0_15;
            zls = pkgs.zls_0_15;
          };
          zig_0_16 = mkZigShell {
            zig = pkgs.zig_0_16;
            zls = pkgs.zls_0_16;
          };
          zig_master = mkZigShell {
            zig = zig-overlay.packages.${system}.master;
            zls = zls.packages.${system}.zls;
          };

          default = zig_0_16;
        }
      );
    };
}
