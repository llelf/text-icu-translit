module Data.Text.ICU.Translit.Internal where

import Foreign
import Data.Text
import Data.Text.Foreign

data UTransliterator
type UChar = Word16

foreign import ccall "trans.h openTrans" openTrans :: Ptr UChar -> Int -> IO (Ptr UTransliterator)
foreign import ccall "trans.h &closeTrans" closeTrans :: FunPtr (Ptr UTransliterator -> IO ())
foreign import ccall "trans.h doTrans" doTrans
    :: Ptr UTransliterator -> Ptr UChar -> Int -> IO Int



data Transliterator = Transliterator { transPtr :: ForeignPtr UTransliterator }
                      deriving Show

transliterator :: Text -> IO Transliterator
transliterator tr =
    useAsPtr tr $ \ptr len -> do
           q <- openTrans ptr (fromIntegral len)
           ref <- newForeignPtr closeTrans q
           touchForeignPtr ref
           return $ Transliterator ref


transliterate :: Transliterator -> Text -> IO Text
transliterate tr txt = do
  (fptr, len) <- asForeignPtr txt
  withForeignPtr fptr $ \ptr ->
      withForeignPtr (transPtr tr) $ \tr_ptr -> do
                         doTrans tr_ptr ptr (fromIntegral len)
                         fromPtr ptr len

