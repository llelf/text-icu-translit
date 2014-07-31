{-# LANGUAGE DeriveDataTypeable #-}
module Data.Text.ICU.Translit.ICUHelper where

import Foreign.C.Types (CInt(..))
import Foreign.Storable (Storable(..))
import Data.Int (Int32)
--import Control.DeepSeq (NFData(..))
import Control.Exception (Exception, throwIO)
import Data.Function (fix)
import Foreign.Ptr (Ptr)
import Foreign.Marshal.Alloc (alloca)
import Foreign.Marshal.Utils (with)
import Foreign.Marshal.Array (allocaArray)
import Data.Int (Int32)
import Data.Typeable (Typeable)
import Foreign.C.String (CString, peekCString)
import Foreign.C.Types (CInt(..))
import Foreign.Storable (Storable(..))
import System.IO.Unsafe (unsafePerformIO)
import Foreign

type UErrorCode = CInt
type UChar = Word16

newtype ICUError = ICUError {
      fromErrorCode :: UErrorCode
    } deriving (Eq, Typeable)

instance Show ICUError where
    show code = "ICUError " ++ errorName code

instance Exception ICUError


#include <unicode/utypes.h>


-- | Deal with ICU functions that report a buffer overflow error if we
-- give them an insufficiently large buffer.  Our first call will
-- report a buffer overflow, in which case we allocate a correctly
-- sized buffer and try again.
handleOverflowError :: (Storable a) =>
                       Int
                    -- ^ Initial guess at buffer size.
                    -> (Ptr a -> Int32 -> Ptr UErrorCode -> IO Int32)
                    -- ^ Function that retrieves data.
                    -> (Ptr a -> Int -> IO b)
                    -- ^ Function that fills destination buffer if no
                    -- overflow occurred.
                    -> IO b
handleOverflowError guess fill retrieve =
  alloca $ \uerrPtr -> flip fix guess $ \loop n ->
    (either (loop . fromIntegral) return =<<) . allocaArray n $ \ptr -> do
      poke uerrPtr 0
      ret <- fill ptr (fromIntegral n) uerrPtr
      err <- peek uerrPtr
      case undefined of
        _| err == (#const U_BUFFER_OVERFLOW_ERROR)
                     -> return (Left ret)
         | err > 0   -> throwIO (ICUError err)
         | otherwise -> Right `fmap` retrieve ptr (fromIntegral ret)


-- | Return a string representing the name of the given error code.
errorName :: ICUError -> String
errorName code = unsafePerformIO $
                 peekCString (u_errorName (fromErrorCode code))

foreign import ccall unsafe "icu.h __hs_u_errorName" u_errorName
    :: UErrorCode -> CString

