{-# LANGUAGE DeriveGeneric  #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE OverloadedStrings #-}

module Main where

import Aws.Lambda
import Aws.Lambda.Runtime
import GHC.Generics
import Data.Aeson
import Data.Aeson.Encode.Pretty
import Data.Either
import Data.Text (Text)
import Data.Text.Lazy (toStrict)
import Data.Text.Lazy.Encoding (decodeUtf8)
import Network.HTTP.Types.Header

main :: IO ()
main =  runLambda run
  where
   run ::  LambdaOptions -> IO (Either a LambdaResult)
   run opts = do
    result <- either (error . show) id $ handler <$> (decodeObj (eventObject opts)) <*> (decodeObj (contextObject opts))
    either error (pure . Right . StandaloneLambdaResult . encodeObj) result

type Request = Value

data Response = Response
  { statusCode :: Int
  , headers :: [(Text, Text)]
  , body :: Text
  , isBase64Encoded :: Bool
  } deriving (Generic, ToJSON)

handler :: Request -> Context -> IO (Either String Response)
handler e context = return
    $ Right
    $ Response 200 mempty (toStrict $ decodeUtf8 $ encodePretty e) False
