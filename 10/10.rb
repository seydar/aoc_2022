#!/usr/bin/env ruby

# Unless, that is, you can design a replacement for the device's video system!
# It seems to be some kind of cathode-ray tube screen and simple CPU that are
# both driven by a precise clock circuit. The clock circuit ticks at a constant
# rate; each tick is called a cycle.

# Start by figuring out the signal being sent by the CPU. The CPU has a single
# register, X, which starts with the value 1. It supports only two instructions:
#   - addx V takes two cycles to complete. After two cycles, the X register is
#     increased by the value V. (V can be negative.)
#   - noop takes one cycle to complete. It has no other effect.

def parse_tape(str)
  lines = str.split "\n"
  tape = lines.map do |line|
    case line
    when "noop"
      0
    when /addx (-?\d+)/
      [0, $1.to_i]
    end
  end.flatten
end

def part_one(tape)
  locations = [20, 60, 100, 140, 180, 220]
  locations.map { |location| (1 + tape[0, location - 1].sum) * location }.sum
end

def sprite_visible?(cycle, x)
  [x - 1, x, x + 1].include? cycle
end

def part_two(tape)
  (1..tape.size).each do |cycle|
    x = (1 + tape[0, cycle].sum) * cycle
    if sprite_visible? cycle, x
      print "#"
    else
      print "."
    end

    if cycle % 40 == 0
      puts
    end
  end
end

tape = parse_tape STDIN.read

case ARGV[0]
when "one"
  p part_one(tape)
when "two"
  p part_two(tape)
end

