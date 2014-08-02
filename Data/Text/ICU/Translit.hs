
module Data.Text.ICU.Translit
    (IO.Transliterator, trans, transliterate) where

import qualified Data.Text.ICU.Translit.Internal as IO
import System.IO.Unsafe
import Data.Text


-- | Construct new transliterator by name. Will throw error if there's
-- no such transliterator
trans :: Text -> IO.Transliterator
trans t = unsafePerformIO $ IO.transliterator t



-- | Transliterate the text using the transliterator
transliterate :: IO.Transliterator -> Text -> Text
transliterate tr txt = unsafePerformIO $ IO.transliterate tr txt

