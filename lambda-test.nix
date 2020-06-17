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
}
