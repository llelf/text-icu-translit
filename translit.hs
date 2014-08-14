
import Data.Text.ICU.Translit
import System.Environment
import qualified Data.Text.IO as T
import qualified Data.Text as T
import System.IO
import Control.Monad

import Pipes
import Pipes.Group as PG
import Pipes.Prelude as Pipes
import Pipes.Text.IO as PT
import Pipes.Text as PT
import Lens.Family2

main = do args <- getArgs
          case args of
            [rule] ->
                go' $ fun (T.pack rule)
            _ ->
                error "Usage"
    where
      fun :: T.Text -> T.Text -> T.Text
      fun rule = transliterate (trans rule)

      go' f = runEffect $
              over PT.lines (PG.maps (>-> Pipes.map f)) PT.stdin >-> PT.stdout

      go :: (T.Text -> T.Text) -> IO ()
      go f = do e <- isEOF
                unless e $ do s <- T.getLine
                              T.putStrLn (f s)
                              go f



