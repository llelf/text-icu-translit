-- |
--  Module:     Data.Text.ICU.Translit
--  License:    BSD-style
--  Maintainer: me@lelf.lu
-- 
-- This module provides the bindings to the transliteration features
-- by the ICU (International Components for Unicode) library.
-- 
-- >>> IO.putStrLn $ transliterate (trans "name-any; ru") "\\N{RABBIT FACE} Nu pogodi!"
-- 🐰 Ну погоди!
-- 
-- >>> IO.putStrLn $ transliterate (trans "nl-title") "gelderse ijssel"
-- Gelderse IJssel
-- 
-- >>> IO.putStrLn $ transliterate (trans "ja") "Amsterdam"
-- アムステルダム
-- 
-- More information about the rules is
-- <http://userguide.icu-project.org/transforms/general here>.



module Data.Text.ICU.Translit
    (IO.Transliterator, trans, transliterate) where

import qualified Data.Text.ICU.Translit.IO as IO
import System.IO.Unsafe
import Data.Text


-- | Construct new transliterator by name. Will throw an error if
-- there is no such transliterator
trans :: Text -> IO.Transliterator
trans t = unsafePerformIO $ IO.transliterator t


-- | Transliterate the text using the transliterator
transliterate :: IO.Transliterator -> Text -> Text
transliterate tr txt = unsafePerformIO $ IO.transliterate tr txt

