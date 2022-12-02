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
  score = if LOSE[match[0]] == match[1]
            0
          elsif match[0].ord == (match[1].ord - 23)
            3
          else
            6
          end

  # ... the score for the shape you selected (1 for Rock, 2 for
  # Paper, and 3 for Scissors)...
  score += match[1].ord - 87
end

def pick_move(match)
  outcome = match[1]
  if outcome == "X" # lose
    LOSE[match[0]]
  elsif outcome == "Y" # draw
    (match[0].ord + 23).chr
  else # win
    BEAT[match[0]]
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


