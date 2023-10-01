{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:

  flake-utils.lib.eachDefaultSystem (system: let 
    pkgs = import nixpkgs { inherit system; };
  in  {
    packages.default = pkgs.stdenv.mkDerivation {
      name = "dtuconnect";
      src = ./.;

      nativeBuildInputs = builtins.attrValues {};
      buildInputs = builtins.attrValues {
        inherit (pkgs) gawk networkmanager;
      };

      installPhase = ''
        install -Dm 755 "iwd.sh" "$out/bin/iwd.sh"
        install -Dm 755 "setup.sh" "$out/bin/dtuconnect"
      '';
    };
  });
}

