{-# LANGUAGE DeriveGeneric  #-}
{-# LANGUAGE DeriveAnyClass #-}

import Aws.Lambda
import GHC.Generics
import Data.Aeson

module Main where

main :: IO ()
main = runLambda run
  where
   run ::  LambdaOptions -> IO (Either String LambdaResult)
   run opts = do
    result <- handler (decodeObj (eventObject opts)) (decodeObj (contextObject opts))
    either (pure . Left . encodeObj) (pure . Right . LambdaResult . encodeObj) result

data Event = Event
  { path :: T.Text
  , body :: Maybe T.Text
  } deriving (Generic, FromJSON)

data Response = Response
  { statusCode :: Int
  , headers :: Value
  , body :: T.Text
  , isBase64Encoded :: Bool
  } deriving (Generic, ToJSON)

handler :: Event -> Context -> IO (Either String Response)
handler Event{body, path} context =
