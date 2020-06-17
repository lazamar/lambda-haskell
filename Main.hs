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
import Data.Either
import Data.Text (Text)
import Network.HTTP.Types.Header

main :: IO ()
main =  runLambda run
  where
   run ::  LambdaOptions -> IO (Either a LambdaResult)
   run opts = do
    result <- handler (decodeObj (eventObject opts)) (decodeObj (contextObject opts))
    either error (pure . Right . LambdaResult . encodeObj) result

type Event = Value

data Response = Response
  { statusCode :: Int
  , headers :: [(Text, Text)]
  , body :: String
  , isBase64Encoded :: Bool
  } deriving (Generic, ToJSON)

handler :: Event -> Context -> IO (Either String Response)
handler e context = return $ Right $ Response 200 mempty
    ("Hello Lambda " ++ show e) False
