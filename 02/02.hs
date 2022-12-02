module Main where

import System.IO
import System.Environment
import Data.List.Split
import Data.Char (ord, chr)

type Match = (Char, Char)

lose :: Char -> Char
lose 'A' = 'Z'
lose 'B' = 'X'
lose 'C' = 'Y'

draw :: Char -> Char
draw c = chr $ ord c + 23

beat :: Char -> Char
beat 'A' = 'Y'
beat 'B' = 'Z'
beat 'C' = 'X'

charTuple :: [String] -> (Char, Char)
charTuple [a, b] = (a !! 0, b !! 0)

readMatches :: IO [Match]
readMatches = do
  input <- getContents
  return . map (charTuple . splitOn " ") . lines $ input

scoreMatch :: Match -> Int
scoreMatch m@(them, us) = (scoreOutcome m) + (moveValue us)
  where
    scoreOutcome :: Match -> Int
    scoreOutcome (them, us) | (lose them) == us = 0
                            | them == us        = 3
                            | otherwise         = 6

    moveValue us = ord us - 87

getMove :: Match -> Match
getMove (them, us) | us == 'X' = (them, lose them)
                   | us == 'Y' = (them, draw them)
                   | us == 'Z' = (them, beat them)

partOne = print . sum . map scoreMatch
partTwo = print . sum . map (scoreMatch . getMove)

main = do
  args <- getArgs
  matches <- readMatches

  if (args !! 0) == "one"
    then partOne matches
    else partTwo matches
