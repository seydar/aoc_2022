import System.IO
import System.Environment
import Data.List.Split
import Data.List

parseFileSystem = 

partOne fs = sum . filter (<= 100_000) . map (du fs) $ allDirs fs

partTwo = find (>= needDelete) . sort . map (du fs) $ allDirs fs

main = do
  args <- getArgs

  fs <- parseFileSystem

  case head args of
    "one" -> print $ partOne fs
    "two" -> print $ partTwo fs
