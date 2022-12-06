#!/usr/bin/env ruby

def unique_substring(string, size)
  string.size.times do |i|
    if string[i, size].split("").uniq.size == size
      return i + size
    end
  end
end

def start_of_packet(string)
  unique_substring string, 4
end

def start_of_message(string)
  unique_substring string, 14
end

def part_one(lines)
  lines.map {|l| start_of_packet l }
end

def part_two(lines)
  lines.map {|l| start_of_message l }
end

inp = STDIN.read.split "\n"

if ARGV[0] == "one"
  puts part_one(inp)
elsif ARGV[0] == "two"
  puts part_two(inp)
end
