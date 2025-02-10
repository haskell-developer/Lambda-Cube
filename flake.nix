{
  description = "Single file Lambda Calculus implementations and presentation slides.";

  inputs = {
    nixpkgs.url = github:nixos/nixpkgs/24.05;
    flake-utils.url = github:numtide/flake-utils;
  };

  outputs = { self , nixpkgs , flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
    let
      compilerVersion = "ghc982";
      pkgs = nixpkgs.legacyPackages.${system};
      hsPkgs = pkgs.haskell.packages.${compilerVersion}.override {
        overrides = hfinal: hprev: {
          lambda-calculus-hs = hfinal.callCabal2nix "lambda-calculus-hs" ./. { };
        };
      };
    in
    rec {
      packages =
        flake-utils.lib.flattenTree
          { lambda-calculus-hs = hsPkgs.lambda-calculus-hs;
            default = hsPkgs.lambda-calculus-hs;
          };

      devShells = {
        default = hsPkgs.shellFor {
          withHoogle = true;
          packages = p: [
            p.lambda-calculus-hs
          ];
          buildInputs = with pkgs;
            [
              cabal-install
              cabal2nix
              haskell-language-server
              haskellPackages.ghcid
              haskellPackages.fourmolu
              haskellPackages.cabal-fmt
            ]
            ++ (builtins.attrValues (import ./scripts.nix { s = pkgs.writeShellScriptBin; }));
          };
      };

      formatter = pkgs.nixfmt-rfc-style;
    });
}
