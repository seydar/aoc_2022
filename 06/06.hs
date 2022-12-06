import System.IO
import System.Environment
import qualified Data.Set as Set
import Data.List

type Signal = String

nubOrd :: Ord a => [a] -> [a] 
nubOrd xs = go Set.empty xs where
  go s (x:xs)
   | x `Set.member` s = go s xs
   | otherwise        = x : go (Set.insert x s) xs
  go _ _              = []

uniqueSubstring :: Int -> String -> Int
uniqueSubstring duration = helper . find (uniq . snd) . zip [duration..] . tails
  where
    uniq sub = (length . nubOrd . take duration $ sub) == duration
    helper Nothing       = -1
    helper (Just (n, _)) = n

packetStart :: Signal -> Int
packetStart = uniqueSubstring 4

messageStart :: Signal -> Int
messageStart = uniqueSubstring 14

partOne = map packetStart . lines
partTwo = map messageStart . lines

main = do
  args <- getArgs
  inp  <- getContents

  case head args of
    "one" -> print $ partOne inp
    "two" -> print $ partTwo inp

