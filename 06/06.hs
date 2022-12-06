import System.IO
import System.Environment
import qualified Data.Set as Set
import Debug.Trace

type Signal = String

nubOrd :: Ord a => [a] -> [a] 
nubOrd xs = go Set.empty xs where
  go s (x:xs)
   | x `Set.member` s = go s xs
   | otherwise        = x : go (Set.insert x s) xs
  go _ _              = []

uniqueSubstring :: String -> Int -> Int
uniqueSubstring str duration = helper str 0 
  where
    uniq sub = (length . nubOrd . take duration $ sub) == duration
    helper sub n
      | length sub < duration = -1
      | uniq sub              = n + duration
      | otherwise             = helper (tail sub) (n + 1)

packetStart :: Signal -> Int
packetStart signal = uniqueSubstring signal 4

messageStart :: Signal -> Int
messageStart signal = uniqueSubstring signal 14

partOne = map packetStart . lines
partTwo = map messageStart . lines

main = do
  args <- getArgs
  inp  <- getContents

  if (args !! 0) == "one"
    then print $ partOne inp
    else print $ partTwo inp

