#!/usr/bin/env ruby

DEBUG = ARGV[1] == "debug"
def d_p(*args); p(*args) if DEBUG; end
def d_puts(*args); puts(*args) if DEBUG; end

def parse_pairs(str)
  pairs = str.split "\n\n"
  pairs.map do |pair|
    pair.split("\n").map do |line|
      eval line # lazy
    end
  end
end

def cmp(left, right, prefix="")
  d_puts "#{prefix}: comparing #{left} to #{right}:"
  if left.is_a?(Numeric) && right.is_a?(Numeric)
    res = left <=> right
    d_puts "#{prefix}  : #{res}"
    res
  elsif left.is_a?(Array) && right.is_a?(Array)
    res = 0
    left.zip(right).each do |l, r|
      d_puts "#{prefix}\t- comparing elt #{l.inspect} to #{r.inspect}"

      # this means that l is longer than r and that we're actively comparing them
  
      d_puts "#{prefix}  : 1" if r == nil
      return 1 if r == nil
      res = cmp(l, r, prefix + "  ")
      d_puts "#{prefix}  : #{res}"
      return res unless res == 0
    end

    return -1 if res == 0 && left.size < right.size

    0
  else
    cmp([*left], [*right], prefix + "  ")
  end
end

def part_one(pairs)
  res = pairs.map {|left, right| cmp(left, right) == -1 }
  d_p res
  res.zip((1..pairs.size)).filter {|bool, i| bool }.sum {|_, i| i }
end

def part_two(pairs)
  dividers = [[[2]], [[6]]]
  packets  = pairs.flatten(1) + dividers
  sorted   = packets.sort {|left, right| cmp left, right }
  dividers.map {|d| sorted.index(d) + 1}.reduce(&:*)
end

pairs = parse_pairs STDIN.read

case ARGV[0]
when "one"
  p part_one(pairs)
when "two"
  p part_two(pairs)
end

