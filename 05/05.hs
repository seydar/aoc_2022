import System.IO
import System.Environment
import Data.List.Split
import Data.Char
import Debug.Trace

type Move   = (Int, Int, Int)
type Stack  = [Crate]
type Stacks = [Stack]
type Crate  = String

move9000 :: Stacks -> Move -> Stacks
move9000 stacks (0, _, _) = stacks
move9000 stacks (qty, f, t) = move9000 stacks' ((qty - 1), f, t)
  where
    (from, to)  = (f - 1, t - 1)
    to'     = (head (stacks !! from)) : (stacks !! to)
    from'   = tail (stacks !! from)
    stacks' = replace (replace stacks to to') from from'

move9001 :: Stacks -> Move -> Stacks
move9001 stacks (qty, f, t) = stacks'
  where
    (from, to) = (f - 1, t - 1)
    to'     = take qty (stacks !! from) ++ (stacks !! to)
    from'   = drop qty (stacks !! from)
    stacks' = replace (replace stacks to to') from from'

replace :: [a] -> Int -> a -> [a]
replace list pos new = pre ++ (new : rest)
  where
    (pre, _:rest) = splitAt pos list

replaceAll :: Stacks -> [Crate] -> Stacks
replaceAll stack crates = map addIf $ zip crates stack
  where
    addIf ("", s) = s
    addIf (c,  s) = c : s

parseMoves :: String -> [Move]
parseMoves = map parseMove . lines

parseMove :: String -> Move
parseMove line = (read qty, read from, read to)
  where
    [_, qty, _, from, _, to] = splitOn " " line

parseStacks :: String -> Stacks
parseStacks stackData = stacks'
  where
    rows    = reverse . lines $ stackData

    header  = filter (/= "") . splitOn " " $ head rows
    size    = length header
    stacks  = emptyStacks size

    body    = tail rows

    lengthen n ls = ls ++ (take (n - (length ls)) $ repeat "")

    parts   = map (lengthen size . parseStackBody []) body
    stacks' = foldl (\s cs -> replaceAll s cs) stacks parts

emptyStacks :: Int -> Stacks
emptyStacks size = take size $ repeat []

parseStackBody :: [Crate] -> String -> [Crate]
parseStackBody cur "" = reverse cur
parseStackBody cur rest = parseStackBody cur' rest'
  where
    cur'  = (clean . take 4 $ rest) : cur
    rest' = drop 4 rest
    clean = filter isAlpha

parseInput :: String -> (Stacks, [Move])
parseInput inp = (stacks, moves)
  where
    [stackData, moveData] = splitOn "\n\n" inp
    stacks = parseStacks stackData
    moves  = parseMoves moveData

partOne stacks moves = map (head . head) $ foldl (\s m -> move9000 s m) stacks moves
partTwo stacks moves = map (head . head) $ foldl (\s m -> move9001 s m) stacks moves

main = do
  args <- getArgs
  inp  <- getContents

  let (stacks, moves) = parseInput inp

  if (args !! 0) == "one"
    then putStrLn $ partOne stacks moves
    else putStrLn $ partTwo stacks moves

