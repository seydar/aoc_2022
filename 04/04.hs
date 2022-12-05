import System.IO
import System.Environment
import Data.List
import Data.List.Split (splitOn)

type ChoreList = [Int] -- alternatively (start, end)
type Pair = (ChoreList, ChoreList)

getPairs :: IO [Pair]
getPairs = do
  inp <- getContents
  return $ map (createRanges . splitOn ",") $ lines inp

createRanges :: [String] -> Pair
createRanges [a, b] = ([(read a1)..(read a2)]
                      ,[(read b1)..(read b2)])
  where
    [a1, a2] = splitOn "-" a
    [b1, b2] = splitOn "-" b

totalOverlap (a, b) = (a \\ b == []) || (b \\ a == [])

anyOverlap (a, b) = (intersect a b) /= []

partOne = length . filter totalOverlap
partTwo = length . filter anyOverlap

main = do
  args  <- getArgs
  pairs <- getPairs

  if (args !! 0) == "one"
    then print $ partOne pairs
    else print $ partTwo pairs
