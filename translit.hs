
import Data.Text.ICU.Translit
import System.Environment
import qualified Data.Text.IO as T
import qualified Data.Text as T
import System.IO
import Control.Monad

main = do args <- getArgs
          case args of
            [rule] ->
                go $ fun (T.pack rule)
            _ ->
                error "Usage"
    where
      fun :: T.Text -> T.Text -> T.Text
      fun rule = transliterate (trans rule)

      go :: (T.Text -> T.Text) -> IO ()
      go f = do e <- isEOF
                unless e $ do s <- T.getLine
                              T.putStrLn (f s)
                              go f

