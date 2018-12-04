-- |
-- Copyright :  (c) Edward Kmett 2018
-- License   :  BSD-2-Clause OR Apache-2.0
-- Maintainer:  Edward Kmett <ekmett@gmail.com>
-- Stability :  experimental
-- Portability: non-portable

module Par.Future
  ( Future
  , newFuture
  , await
  ) where

import Control.Applicative
import Control.Monad.State
import Par.Class
import Par.Promise
import Ref.Signal
import Ref.Key

newtype Future m a = Future (Promise m a)

newFuture :: (MonadPar m, MonadState s m, HasSignalEnv s m, MonadKey m) => m a -> m (Future m a)
newFuture m = do
  p <- newPromise_
  fork $ do
    a <- m
    unsafeFulfill p a
  pure $ Future p

await :: (MonadPar m, MonadState s m, HasSignalEnv s m, Alternative m) => Future m a -> m a
await (Future p) = demand p
