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
    result <- either (error . show) id $ handler <$> (decodeObj (eventObject opts)) <*> (decodeObj (contextObject opts))
    either error (pure . Right . StandaloneLambdaResult . encodeObj) result

data Event = Event
  { path :: Text
  , body :: Maybe Text
  } deriving (Generic, FromJSON)

data Response = Response
  { statusCode :: Int
  , headers :: [(Text, Text)]
  , body :: Text
  , isBase64Encoded :: Bool
  } deriving (Generic, ToJSON)

handler :: Event -> Context -> IO (Either String Response)
handler Event{body, path} context = return $ Right $ Response 200 mempty "Hello LAMBDA MOTHERFOCKER!!" False
