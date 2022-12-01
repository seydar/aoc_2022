#!/usr/bin/env ruby
# https://adventofcode.com/2022/day/1

# The jungle must be too overgrown and difficult to navigate in vehicles or
# access from the air; the Elves' expedition traditionally goes on foot. As
# your boats approach land, the Elves begin taking inventory of their supplies.
# One important consideration is food - in particular, the number of Calories
# each Elf is carrying (your puzzle input).
elves = [[]]
while line = STDIN.gets
  line = line.chomp

  # The Elves take turns writing down the number of Calories contained by the
  # various meals, snacks, rations, etc. that they've brought with them, one
  # item per line. Each Elf separates their own inventory from the previous
  # Elf's inventory (if any) by a blank line.
  #
  # Empty line == new elf
  if line == ""
    elves << []
  # Non-empty line == add to the latest elf's list of provisions
  else
    elves.last << line.to_i
  end
end

AOC_PART = ARGV[0] || "one"
if AOC_PART == "one"
  puts elves.map {|elf| elf.sum }.max
elsif AOC_PART == "two"
  puts elves.map {|elf| elf.sum }.sort[-3..-1].sum
end

