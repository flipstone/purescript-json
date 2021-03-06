module Test.Main where

import Control.Monad.Eff
import Control.Monad.Eff.Exception

import Debug.Trace

import qualified Data.Set as S
import qualified Data.Map as M
import Data.Tuple
import Data.Maybe
import Data.Either

import Data.JSON

import Test.PSpec
import Test.PSpec.Mocha
import Test.Assert.Simple

itDecode t = it $ t ++ " should decode"

itEncode t = it $ t ++ " should encode"

main = runMocha $ do
  describe "FromJSON" $ do
    itDecode "Number"  $ Just 12 @=? (decode "12" :: Maybe Number)
    itDecode "String"  $ Just "foo" @=? (decode "\"foo\"" :: Maybe String)
    itDecode "Boolean" $ Just true @=? (decode "true" :: Maybe Boolean)
    itDecode "Unit"    $ Just unit @=? (decode "null" :: Maybe Unit)

    itDecode "Array"   $ Just [1,2,3,2,1] @=? (decode "[1,2,3,2,1]" :: Maybe [Number])
    itDecode "Set"     $ Just (S.fromList [1,2,3]) @=? (decode "[1,2,3,2,1]" :: Maybe (S.Set Number))
    itDecode "Tuple"   $ Just (Tuple "kevin" 18)   @=? (decode "[\"kevin\", 18]" :: Maybe (Tuple String Number))
    itDecode "Map"     $ Just (M.fromList [Tuple "a" 3, Tuple "b" 2]) @=? (decode "{\"a\": 1, \"b\": 2, \"a\": 3}" :: Maybe (M.Map String Number))

    itDecode "Nothing" $ Just Nothing  @=? (decode "\"a\"" :: Maybe (Maybe Number))
    itDecode "Just"    $ Just (Just 3) @=? (decode "3" :: Maybe (Maybe Number))

    itDecode "Left"    $ Just (Left 4) @=? (decode "{\"Left\": 4}" :: Maybe (Either Number Boolean))
    itDecode "Right"   $ Just (Right true) @=? (decode "{\"Right\": true}" :: Maybe (Either Number Boolean))
    itDecode "Both"    $ Nothing @=? (decode "{\"Left\": 4, \"Right\": true}" :: Maybe (Either Number Boolean))

    itDecode "Value"   $ (Just (JArray [JNumber 1, JBool true, JObject $ M.fromList
               [Tuple "foo" (JNumber 12), Tuple "bar" (JArray [JString "baz", JNumber 43])]]))
      @=? (decode "[1,true,{\"foo\": 12, \"bar\": [\"baz\", 43]}]" :: Maybe JValue)

  describe "ToJSON" $ do
    itEncode "Number"  $ "12" @=? encode 12
    itEncode "String"  $ "\"foo\"" @=? encode "foo"
    itEncode "Bool"    $ "true" @=? encode true
    itEncode "Unit"    $ "null" @=? encode unit

    itEncode "Array"   $ "[1,2,3,2,1]" @=? encode [1,2,3,2,1]
    itEncode "Set"     $ "[1,2,3]" @=? encode (S.fromList [1,2,3,2,1])
    itEncode "Tuple"   $ "[\"kevin\",18]" @=? encode (Tuple "kevin" 18)
    itEncode "Map"     $ "{\"a\":1,\"b\":2}" @=? encode (M.fromList [Tuple "a" 1, Tuple "b" 2])

    itEncode "Nothing" $ "null" @=? encode (Nothing :: Maybe Number)
    itEncode "Just"    $ "3"    @=? encode (Just 3)

    itEncode "Left"    $ "{\"Left\":4}" @=? encode (Left 4     :: Either Number Boolean)
    itEncode "Right"   $ "{\"Right\":true}" @=? encode (Right true :: Either Number Boolean)

    itEncode "Value"   $ "[1,true,{\"bar\":[\"baz\",43],\"foo\":12}]"
      @=? encode (JArray [JNumber 1, JBool true, JObject $ M.fromList [Tuple "foo" (JNumber 12), Tuple "bar" (JArray [JString "baz", JNumber 43])]])
