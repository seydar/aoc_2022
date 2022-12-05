#!/usr/bin/env ruby

def parse_stacks(data)
  header, *rows = data.split("\n").reverse

  # This is perhaps overkill -- could also have `num = header.split("\s").size`
  # and `stacks = Hash.new {|h, k| h[k] = [] }`
  stacks = header.split("\s").map {|s| [s.to_i, []] }.to_h

  rows.each do |row|
    # {3,4} means we're chunking the string into groups of 3 or 4 characters
    # (with a preference for 4)
    parts = row.scan /.{3,4}/
    parts = parts.map {|p| p.scan(/\w/)[0] }

    # Now, put the crates into their stacks
    stacks.size.times do |i|
      stacks[i + 1] << parts[i] if parts[i]
    end
  end

  stacks
end

def parse_moves(data)
  data.split("\n").map {|l| l.scan(/\d+/).map(&:to_i) }
end

def part1(stacks, moves)
  moves.each do |qty, from, to|
    qty.times { stacks[to].push stacks[from].pop }
  end

  stacks.map {|k, vs| vs.last }.join
end

def part2(stacks, moves)
  moves.each do |qty, from, to|
    stacks[to] += stacks[from][-qty..-1]
    qty.times { stacks[from].pop }
  end

  stacks.map {|k, vs| vs.last }.join
end

stacks, moves = STDIN.read.split("\n\n")
stacks = parse_stacks stacks
moves  = parse_moves moves

if ARGV[0] == "one"
  puts part1(stacks, moves)
elsif ARGV[0] == "two"
  puts part2(stacks, moves)
end

