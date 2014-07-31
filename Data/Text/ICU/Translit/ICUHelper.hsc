{-# LANGUAGE DeriveDataTypeable, MultiWayIf #-}
module Data.Text.ICU.Translit.ICUHelper
    (
      ICUError(..)
    , UChar
    , UErrorCode
    , isFailure
    , errorName
    , handleError
    , handleFilledOverflowError
    , throwOnError
    ) where


-- Many functions in this module are straight from the
-- Data.Text.ICU.Error.Internal (text-icu).
-- 
-- XXX TODO:
--   ⋆ export this and similar functionality somewhere;
-- or
--   ⋆ merge text-icu-* into text-icu?


import Foreign.Storable (Storable(..))
import Data.Int (Int32)
import Control.Exception (Exception, throwIO)
import Foreign.Marshal.Utils (with)
import Data.Typeable (Typeable)
import Foreign.C.Types (CInt(..))
import Foreign.C.String (CString, peekCString)
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


-- | Indicate whether the given error code is a failure.
isFailure :: ICUError -> Bool
{-# INLINE isFailure #-}
isFailure = (> 0) . fromErrorCode


-- | Throw an exception if the given code is actually an error.
throwOnError :: UErrorCode -> IO ()
{-# INLINE throwOnError #-}
throwOnError code = do
  let err = (ICUError code)
  if isFailure err
    then throwIO err
    else return ()



handleError :: (Ptr UErrorCode -> IO a) -> IO a
{-# INLINE handleError #-}
handleError action = with 0 $ \errPtr -> do
                       ret <- action errPtr
                       throwOnError =<< peek errPtr
                       return ret



-- | Deal with ICU functions that report a buffer overflow error if we
-- give them an insufficiently large buffer.  The difference between
-- this function and
-- 'Data.Text.ICU.Error.Internal.handleOverflowError' is that this one
-- doesn't change the contents of the provided buffer, while the
-- latter assumes buffers to be write-only.
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

