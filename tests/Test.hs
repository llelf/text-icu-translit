{-# LANGUAGE OverloadedStrings #-}

import Test.QuickCheck
import Data.Text (Text)
import qualified Data.Text as T
import qualified Data.Text.ICU as U
import Data.Text.ICU.Translit
import Text.Printf
import Data.Char

import Test.Framework
import Test.Framework.Providers.QuickCheck2

-- newtype Random a = Random { unRandom :: a } deriving Show


instance Arbitrary Text where
    arbitrary = fmap T.pack arbitrary
    shrink = fmap T.pack . shrink . T.unpack

-- instance Arbitrary a => Arbitrary (Random a) where
--     arbitrary = fmap Random arbitrary


samples :: [Text]
samples = ["hello","текст","维基百科：海納百川，有容乃大"]


newtype IdempTr = IdempTr Text deriving Show



instance Arbitrary IdempTr where
    arbitrary = elements transes0
        where transes0 = map IdempTr ["ru-en", "en-ru"]

hexUnicode :: Text -> Text
hexUnicode txt = T.pack $ concat [ fmt c | c <- T.unpack txt ]
    where fmt c = printf (if ord c < 0x10000 then "U+%04X" else "U+%X") (ord c)


prop_idemp (IdempTr t,s) = transliterate tr (transliterate tr s) == transliterate tr s
    where tr = trans t
prop_toLower' t = U.toLower U.Root t == transliterate (trans "Lower") t
prop_toLower t = T.toLower t == transliterate (trans "Lower") t
prop_NFC t = U.normalize U.NFC t == transliterate (trans "NFC") t
prop_hexUnicode t = hexUnicode t == transliterate (trans "hex/unicode") t



main = defaultMain [tests]

tests :: Test
tests = testGroup "props" [
         testProperty "idemp" prop_idemp,
         testProperty "toLower'" prop_toLower',
         testProperty "toLower" prop_toLower,
         testProperty "NFC" prop_NFC,
         testProperty "hexUnicode" prop_hexUnicode
        ]




