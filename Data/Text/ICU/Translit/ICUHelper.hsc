{-# LANGUAGE DeriveDataTypeable, MultiWayIf #-}
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
-- give them an insufficiently large buffer.  The difference between
-- this function and
-- 'Data.Text.ICU.Error.Internal.handleOverflowError' is that our
-- buffer is filled with data.
handleFilledOverflowError :: (Storable a) =>
                             Ptr a
                          -- ^ Initial buffer.
                          -> Int
                          -- ^ Initial buffer size.
                          -> (Ptr a -> Int32 -> Ptr UErrorCode -> IO Int32)
                          -- ^ Function that retrieves data.
                          -> (Ptr a -> Int -> IO b)
                          -- ^ Function that fills destination buffer if no
                          -- overflow occurred.
                          -> IO b
handleFilledOverflowError text len0 fill retrieve =
    do buf0 <- mallocArray len0
       copyArray buf0 text len0
       go buf0 len0
    where
      go buf len = alloca $ \errPtr -> do
                     poke errPtr 0
                     len' <- fill buf (fromIntegral len) errPtr
                     err <- peek errPtr
                     if | err == (#const U_BUFFER_OVERFLOW_ERROR)
                            -> do buf' <- reallocArray buf (fromIntegral len')
                                  go buf' (fromIntegral len')
                        | err > 0
                            -> throwIO (ICUError err)
                        | otherwise
                            -> retrieve buf (fromIntegral len')








-- | Return a string representing the name of the given error code.
errorName :: ICUError -> String
errorName code = unsafePerformIO $
                 peekCString (u_errorName (fromErrorCode code))

foreign import ccall unsafe "icu.h __hs_u_errorName" u_errorName
    :: UErrorCode -> CString

