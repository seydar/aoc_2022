#!/usr/bin/env ruby
require 'set'

class Knot
  attr_accessor :position
  attr_accessor :history

  def initialize
    @position = [0, 0] # x, y
    @history  = Set.new
    @history << @position
  end

  def up!;    change_pos( 0,  1); end
  def down!;  change_pos( 0, -1); end
  def left!;  change_pos(-1,  0); end
  def right!; change_pos( 1,  0); end

  def change_pos(dx, dy)
    position[0] += dx
    position[1] += dy

    history << position
  end

  def chase!(knot)
    # only chase if we are beyond 1 difference in any axis
    return unless (@position[0] - knot.position[0]).abs > 1 ||
                  (@position[1] - knot.position[1]).abs > 1

    # one axis will be off by one (match that)
    # the other will be off by two (increase by one)
    @position = @position.zip(knot.position).map do |t, h|
      (t - h).abs == 1 ? h : (t + h) / 2
    end

    @history << @position
  end
end

class Rope
  attr_accessor :knots

  def initialize(knots)
    @knots = knots
  end

  def operate(dir, n)
    case dir
    when :up;    n.times { knots.first.up!;    follow_knots }
    when :down;  n.times { knots.first.down!;  follow_knots }
    when :left;  n.times { knots.first.left!;  follow_knots }
    when :right; n.times { knots.first.right!; follow_knots }
    end
  end

  def follow_knots
    knots.each_cons(2) {|h, t| t.chase! h }
  end
end

def parse_instructions(str)
  lines = str.split("\n")
  lines.map do |line|
    case line
    when /R (\d+)/
      [:right, $1.to_i]
    when /L (\d+)/
      [:left, $1.to_i]
    when /U (\d+)/
      [:up, $1.to_i]
    when /D (\d+)/
      [:down, $1.to_i]
    end
  end
end

def part_one(inp)
  knots = 10.times.map { Knot.new }
  rope  = Rope.new knots

  inp.each do |dir, n|
    rope.operate dir, n
  end

  rope.knots.last.history.size
end

inp = parse_instructions STDIN.read

case ARGV[0]
when "one"
  p part_one(inp)
when "two"
  p part_two(inp)
end

