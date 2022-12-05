#!/usr/bin/env ruby

def create_ranges(a, b)
  a1, a2 = a.split "-"
  b1, b2 = b.split "-"
  [(a1..a2).to_a, (b1..b2).to_a]
end

# In how many assignment pairs does one range fully contain the other?
def part1(pairs)
  pairs.filter {|a, b| (a - b == []) || (b - a == []) }
end

# In how many assignment pairs do the ranges overlap?
def part2(pairs)
  pairs.filter {|a, b| a & b != [] }
end

lines = STDIN.read.split("\n")
pairs = lines.map do |line|
  a, b = line.split(",")
  create_ranges a, b
end

if ARGV[0] == "one"
  puts part1(pairs).size
elsif ARGV[0] == "two"
  puts part2(pairs).size
end
