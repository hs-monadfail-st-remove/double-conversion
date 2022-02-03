{-# LANGUAGE CPP, MagicHash, Rank2Types, TypeFamilies #-}
-- |
-- Module      : Data.Double.Conversion.TextBuilder
-- Copyright   : (c) 2011 MailRank, Inc.
--
-- License     : BSD-style
-- Maintainer  : bos@serpentine.com
-- Stability   : experimental
-- Portability : GHC
--
-- Fast, efficient support for converting between double precision
-- floating point values and text.
--

module Data.Double.Conversion.Internal.TextBuilder
    (
      convert
    ) where

import Control.Monad (when)
#if MIN_VERSION_base(4,4,0)
import Control.Monad.ST.Unsafe (unsafeIOToST)
#else
import Control.Monad.ST (unsafeIOToST)
#endif
import Data.Double.Conversion.Internal.FFI (ForeignFloating)
import qualified Data.Text.Array as A
import Data.Text.Internal.Builder (Builder, writeN)
import Foreign.C.Types (CDouble, CFloat, CInt)
import GHC.Prim (MutableByteArray#)

-- | Not implemented yet 
convert :: (RealFloat a, RealFloat b, b ~ ForeignFloating a) => String -> CInt
        -> (forall s. b -> MutableByteArray# s -> IO CInt)
        -> a -> Builder
{-# SPECIALIZE convert :: String -> CInt -> (forall s. CDouble -> MutableByteArray# s -> IO CInt) -> Double -> Builder #-}
{-# SPECIALIZE convert :: String -> CInt -> (forall s. CFloat -> MutableByteArray# s -> IO CInt) -> Float -> Builder #-}
{-# INLINABLE convert #-}
#if MIN_VERSION_text(2,0,0)
convert func len act val = writeN (fromIntegral len) $ \(A.MutableByteArray maBa) _ -> do
#else
convert func len act val = writeN (fromIntegral len) $ \(A.MArray maBa) _ -> do
#endif
    size <- unsafeIOToST $ act (realToFrac val) maBa
    when (size == -1) .
        error $ "Data.Double.Conversion.Text." ++ func ++
                ": conversion failed (invalid precision requested)"
    return ()
