
module Data.Text.ICU.Translit where


import Data.Text.ICU.Translit.Internal as IO
import System.IO.Unsafe
import Data.Text



trans :: Text -> Transliterator
trans t = unsafePerformIO $ IO.transliterator t


transliterate :: Transliterator -> Text -> Text
transliterate tr txt = unsafePerformIO $ IO.transliterate tr txt


