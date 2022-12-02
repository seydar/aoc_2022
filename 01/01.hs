import System.IO
import System.Environment
import Data.List
import Data.List.Split

type Elf = [Int]

readProvisions :: IO [Elf]
readProvisions = do
  input <- getContents
  let provisions = splitOn "\n\n" input
  return $ map parseElf provisions

parseElf :: String -> Elf
parseElf = map (\s -> read s :: Int) . lines

partOne = print . maximum . map sum
partTwo = print . sum . take 3 . reverse . sort . map sum

main = do
  args <- getArgs
  elves <- readProvisions

  if (args !! 0) == "one"
    then partOne elves
    else partTwo elves
