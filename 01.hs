import System.IO
import System.Environment
import Data.List

type Elf = [Int]

readProvisions :: [Elf] -> IO [Elf]
readProvisions elves = do
  done <- isEOF
  if done
    then return elves
    else do
      elf <- readElf []
      readProvisions (elf:elves)

readElf :: Elf -> IO Elf
readElf provisions = do
  done <- isEOF
  if done
    then return provisions
    else do
      line <- getLine
      if line == ""
        then return provisions
        else readElf ((read line):provisions)

partOne = putStrLn . show . foldl max 0 . map sum
partTwo = putStrLn . show . sum . take 3 . reverse . sort . map sum

main = do
  args <- getArgs
  elves <- readProvisions [[]]

  if (args !! 0) == "one"
    then partOne elves
    else partTwo elves
