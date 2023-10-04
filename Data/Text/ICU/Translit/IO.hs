module Data.Text.ICU.Translit.IO
    (Transliterator,
     transliterator,
     transliterate) where

import Foreign
import Data.Text
import Data.Text.Foreign
import Data.Text.ICU.Translit.ICUHelper

data UTransliterator

foreign import ccall "trans.h __hs_translit_open_trans" openTrans
    :: Ptr UChar -> Int -> Ptr UErrorCode -> IO (Ptr UTransliterator)
foreign import ccall "trans.h &__hs_translit_close_trans" closeTrans
    :: FunPtr (Ptr UTransliterator -> IO ())
foreign import ccall "trans.h __hs_translit_do_trans" doTrans
    :: Ptr UTransliterator -> Ptr UChar -> Int32 -> Int32
    -> Ptr UErrorCode -> IO Int32



data Transliterator = Transliterator {
      transPtr :: ForeignPtr UTransliterator,
      transSpec :: Text
    }


instance Show Transliterator where
    show tr = "Transliterator " ++ show (transSpec tr)



transliterator :: Text -> IO Transliterator
transliterator spec =
    useAsPtr spec $ \ptr len -> do
           q <- handleError $ openTrans (castPtr ptr) (fromIntegral len)
           ref <- newForeignPtr closeTrans q
           touchForeignPtr ref
           return $ Transliterator ref spec


transliterate :: Transliterator -> Text -> IO Text
transliterate tr txt = do
  (fptr, len) <- asForeignPtr txt
  withForeignPtr fptr $ \ptr ->
      withForeignPtr (transPtr tr) $ \tr_ptr -> do
             handleFilledOverflowError ptr (fromIntegral len)
                 (\dptr dlen ->
                        doTrans tr_ptr (castPtr dptr) (fromIntegral len) (fromIntegral dlen))
                 (\dptr dlen ->
                        fromPtr (castPtr dptr) (fromIntegral dlen))


