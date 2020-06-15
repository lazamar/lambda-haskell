{ mkDerivation, aeson, aws-lambda-haskell-runtime, base, stdenv
, text
}:
mkDerivation {
  pname = "lambda-test";
  version = "0.1.0.0";
  src = ./.;
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [
    aeson aws-lambda-haskell-runtime base text
  ];
  license = "unknown";
  hydraPlatforms = stdenv.lib.platforms.none;
}
