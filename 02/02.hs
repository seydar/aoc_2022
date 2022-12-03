module Main where

import System.IO (getContents)
import System.Environment (getArgs)

data Shape = Rock | Paper | Scissors
  deriving (Show, Ord, Eq, Enum)

type Match = (Shape, Shape)

betterShape :: Shape -> Shape
betterShape Scissors = Rock
betterShape      shp = succ shp

worseShape :: Shape -> Shape
worseShape Rock = Scissors
worseShape  shp = pred shp

charToShape "A" = Rock
charToShape "B" = Paper
charToShape "C" = Scissors
charToShape "X" = Rock
charToShape "Y" = Paper
charToShape "Z" = Scissors

shapeTuple :: [String] -> (Shape, Shape)
shapeTuple [a, b] = (charToShape a, charToShape b)

scoreMatch :: Match -> Int
scoreMatch m@(them, us) = (scoreOutcome m) + (moveValue us)
  where
    scoreOutcome :: Match -> Int
    scoreOutcome (them, us) | (betterShape us) == them = 0
                            | us == them               = 3
                            | otherwise                = 6

    moveValue us = fromEnum us + 1

getMove :: Match -> Match
getMove (them, Rock)     = (them, worseShape them)
getMove (them, Paper)    = (them, them)
getMove (them, Scissors) = (them, betterShape them)

partOne = print . sum . map scoreMatch
partTwo = print . sum . map (scoreMatch . getMove)

readMatches :: IO [Match]
readMatches = do
  input <- getContents
  return . map (shapeTuple . words) . lines $ input

main = do
  args <- getArgs
  matches <- readMatches

  if (args !! 0) == "one"
    then partOne matches
    else partTwo matches
