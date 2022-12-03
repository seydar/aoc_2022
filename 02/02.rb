#!/usr/bin/env ruby

# Opponent on the left => My move
LOSE = {"A" => "Z",
        "B" => "X",
        "C" => "Y"}

BEAT = {"A" => "Y",
        "B" => "Z",
        "C" => "X"}

# The winner of the whole tournament is the player with the highest score.
# Your total score is the sum of your scores for each round. The score for
# a single round is the score for the shape you selected (1 for Rock, 2 for
# Paper, and 3 for Scissors) plus the score for the outcome of the round (0
# if you lost, 3 if the round was a draw, and 6 if you won).
def score_match(match)
  # ... the score for the outcome of the round (0
  # if you lost, 3 if the round was a draw, and 6 if you won).
  score = ((match[1].ord - match[0].ord) + 2) % 3 * 3

  # ... the score for the shape you selected (1 for Rock, 2 for
  # Paper, and 3 for Scissors)...
  score += match[1].ord - 'W'.ord
end

def pick_move(match)
  them, outcome = *match

  case outcome
  when "X"
    LOSE[them]
  when "Y"
    (them.ord + 23).chr
  when "Z"
    BEAT[them]
  end
end

lines = STDIN.read.split "\n"

AOC_PART = ARGV[0] || "one"
if AOC_PART == "one"
  scores = lines.map {|l| score_match l.split(" ") }
  puts scores.sum
elsif AOC_PART == "two"
  scores = lines.map do |l|
    strategy = l.split(" ")
    score_match [strategy[0], pick_move(strategy)]
  end
  puts scores.sum
end


