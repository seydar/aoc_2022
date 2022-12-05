#!/usr/bin/env ruby

def compartments(sack)
  median       = sack.size / 2
  [sack[0..median - 1].split(""), sack[median..-1].split("")]
end

def priority(letter)
  case letter
  when "A".."Z"
    letter.ord - "A".ord + 27
  when "a".."z"
    letter.ord - "a".ord + 1
  end
end

def part1(sacks)
  # assume only one common item
  common = sacks.map {|s| compartments(s).reduce(&:&)[0] }
  common.map {|item| priority item }.sum
end

def part2(sacks)
  badges = sacks.each_slice(3).map do |group|
    group.map {|s| s.split("") }.reduce(&:&)[0]
  end
  puts badges.map {|b| priority b }.sum
end

sacks = STDIN.read.split "\n"

case ARGV[0]
when "one"
  puts part1(sacks)
when "two"
  puts part2(sacks)
end

