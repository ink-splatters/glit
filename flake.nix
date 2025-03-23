{
  description = "Description for the project";

  inputs = {
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";

    fenix = {
      url = "github:nix-community/fenix/monthly";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        rust-analyzer-src.follows = "";
      };
    };
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} (let
      systems = import inputs.systems;
    in {
      inherit systems;
      perSystem = {
        self',
        inputs',
        pkgs,
        ...
      }: {
        packages.rust-toolchain = let
          inherit (inputs'.fenix.packages.minimal) toolchain;
        in
          toolchain;

        devShells.default = pkgs.mkShell {
          nativeBuildInputs = [self'.packages.rust-toolchain];

          buildInputs = with pkgs; [
            pkg-config
            openssl.dev
          ];
        };
        formatter = pkgs.alejandra;
      };
    });
}
