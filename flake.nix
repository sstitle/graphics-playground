{
  description = "Development environment with nickel and mask";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-parts.url = "github:hercules-ci/flake-parts";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs =
    inputs@{ self, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      perSystem =
        {
          config,
          self',
          inputs',
          pkgs,
          system,
          ...
        }:
        let
          treefmtEval = inputs.treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
          bx-source = pkgs.callPackage ./nix/derivations/sources/bx.nix { };
          bimg-source = pkgs.callPackage ./nix/derivations/sources/bimg.nix { };
          bgfx-source = pkgs.callPackage ./nix/derivations/sources/bgfx.nix { };
          bgfx = pkgs.callPackage ./nix/derivations/bgfx.nix {
            inherit bx-source bimg-source bgfx-source;
          };
        in
        {
          devShells.default = pkgs.mkShell {
            buildInputs = with pkgs; [
              git
              nickel
              mask
            ];

            shellHook = ''
              echo "🚀 Development environment loaded!"
              echo "Available tools:"
              echo "  - nickel: Configuration language"
              echo "  - mask: Task runner"
              echo ""
              echo "Run 'mask --help' to see available tasks."
              echo "Run 'nix fmt' to format all files."
            '';
          };

          packages = {
            inherit
              bx-source
              bimg-source
              bgfx-source
              bgfx
              ;
          };

          formatter = treefmtEval.config.build.wrapper;

          checks = {
            formatting = treefmtEval.config.build.check self;
          };
        };
    };
}
