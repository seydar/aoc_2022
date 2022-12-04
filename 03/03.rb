#!/usr/bin/env ruby

def priority(letters)
  letters.map do |letter|
    if ("A".."Z").include? letter
      letter.ord - "A".ord + 27
    else
      letter.ord - "a".ord + 1
    end
  end.sum
end

def rucksacks(rucksacks)
  rucksacks.split "\n"
end

def compartments(sack)
  median       = sack.size / 2
  compartments = [sack[0..median - 1].split(""),
                  sack[median..-1].split("")]
end

sacks = rucksacks STDIN.read

AOC_PART = ARGV[0] || "one"
if AOC_PART == "one"
  common = sacks.map {|s| compartments(s).reduce &:& }
  puts common.map {|item| priority item }.sum
elsif AOC_PART == "two"
  badges = sacks.each_slice(3).map do |s1, s2, s3|
    s1.split("") & s2.split("") & s3.split("")
  end
  puts badges.map {|b| priority b }.sum
end

