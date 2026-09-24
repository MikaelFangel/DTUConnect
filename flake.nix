{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:

  flake-utils.lib.eachSystem
    (builtins.filter (system: system != "x86_64-darwin") flake-utils.lib.defaultSystems)
    (system: let 
    pkgs = import nixpkgs { inherit system; };
  in  {
    packages.default = pkgs.stdenv.mkDerivation {
      name = "dtuconnect";
      src = ./.;

      nativeBuildInputs = builtins.attrValues { inherit (pkgs) makeWrapper; };
      buildInputs = builtins.attrValues { inherit (pkgs) gawk ; };

      installPhase = ''
        install -Dm 755 "setup.sh" "$out/bin/dtuconnect"
      '';

      postFixup = ''
        wrapProgram "$out/bin/dtuconnect" \
          --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.gawk ]};
      '';
    };
  });
}
