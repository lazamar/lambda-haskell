# import the sources
{ sources ? import ./nix/sources.nix }:

# use the sources :)
with { overlay = _: pkgs: { niv = import sources.niv {}; }; };

let
    pkgs = (import (sources.nixpkgs-static + "/survey/default.nix") {
      normalPkgs = import sources.nixpkgs {};
    }).pkgs;

    gitignoreSource = (import sources.gitignore { lib = pkgs.lib; }).gitignoreSource;

    lambda-test =
        pkgs.haskell.lib.overrideCabal
            (pkgs.haskellPackages.callCabal2nix "lambda-test" (gitignoreSource ./.) {})
            (old: {
                  hydraPlatforms = pkgs.stdenv.lib.platforms.none;
                  configureFlags = [
                    "-flambda"
                    "--ghc-option=-optl=-static"
                    "--extra-lib-dirs=${pkgs.gmp6.override { withStatic = true; }}/lib"
                    "--extra-lib-dirs=${pkgs.zlib.static}/lib"
                    "--extra-lib-dirs=${pkgs.libffi.overrideAttrs (old: { dontDisableStatic = true; })}/lib"
                    "--disable-executable-stripping"
                  ];
            });

    function-zip = pkgs.runCommandNoCC "lambda-test.zip" { buildInputs = [ pkgs.zip ]; }
      ''
          mkdir -p $out
          cp ${lambda-test}/bin/lambda-test bootstrap
          zip $out/function.zip bootstrap
      '';
in
{ inherit
    lambda-test
    function-zip ;
}
