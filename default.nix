# import the sources
{ sources ? import ./nix/sources.nix }:

# use the sources :)
with { overlay = _: pkgs: { niv = import sources.niv {}; }; };

let
    pkgs = (import (sources.nixpkgs-static + "/survey/default.nix") {}).pkgs;

    lambda-test-def =
        { mkDerivation, aeson, aws-lambda-haskell-runtime, base, http-types
        , stdenv, text
        }:
        mkDerivation {
            pname = "lambda-test";
            version = "0.1.0.0";
            src = ./.;
            isLibrary = false;
            isExecutable = true;
            executableHaskellDepends = [
              aeson aws-lambda-haskell-runtime base http-types text
            ];
            license = "unknown";
            hydraPlatforms = stdenv.lib.platforms.none;
            configureFlags = [
              "-flambda"
              "--ghc-option=-optl=-static"
              "--extra-lib-dirs=${pkgs.gmp6.override { withStatic = true; }}/lib"
              "--extra-lib-dirs=${pkgs.zlib.static}/lib"
              "--extra-lib-dirs=${pkgs.libffi.overrideAttrs (old: { dontDisableStatic = true; })}/lib"
              "--disable-executable-stripping"
            ];
        };

    lambda-test = pkgs.haskellPackages.callPackage lambda-test-def {};

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
