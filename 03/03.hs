import System.IO
import System.Environment
import Data.Char (ord)
import Data.List (intersect)

type Rucksack = [Char]

rucksacks :: IO [Rucksack]
rucksacks = getContents >>= return . lines

compartments :: Rucksack -> [Rucksack]
compartments rs = [left, right]
  where
    left  = take ((length rs) `div` 2) rs
    right = drop ((length rs) `div` 2) rs

priority :: Char -> Int
priority ltr | elem ltr ['a'..'z'] = ord ltr - ord 'a' + 1
             | elem ltr ['A'..'Z'] = ord ltr - ord 'A' + 27

chunksOf :: Int -> [a] -> [[a]]
chunksOf _ [] = []
chunksOf n ls = (take n ls) : (chunksOf n (drop n ls))

partOne = sum . map (priority . head . foldl1 intersect . compartments)
partTwo = sum . map (priority . head . foldl1 intersect) . chunksOf 3

main = do
  args  <- getArgs
  sacks <- rucksacks

  if (args !! 0) == "one"
    then print $ partOne sacks
    else print $ partTwo sacks
