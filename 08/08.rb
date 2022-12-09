#!/usr/bin/env ruby

class Forest
  include Enumerable

  attr_accessor :trees # matrix for the trees
  attr_accessor :width
  attr_accessor :height

  def self.parse(inp)
    trees = inp.split("\n").map {|l| l.split "" }
    new trees
  end

  def initialize(trees)
    @trees  = trees
    @height = trees.size
    @width  = trees[0].size # arbitrary
  end

  # i is x-coord (moving across columns)
  # j is y-coord (moving across rows)
  # (0, 0) is top left
  #
  # This could be short-circuited for a minor speedup, but I prefer
  # the code as-is
  def visible?(i, j)
    peak = trees[i][j]

    # from the top
    top = (0..i - 1).all? {|x| trees[x][j] < peak }

    # from the bottom
    bottom = (i + 1..height - 1).all? {|x| trees[x][j] < peak }

    # from the left
    left = (0..j - 1).all? {|y| trees[i][y] < peak }

    # from the right
    right = (j + 1..width - 1).all? {|y| trees[i][y] < peak }

    top || bottom || left || right
  end

  def scenic_score(i, j)
    peak   = trees[i][j]
    scores = 1..[width, height].max
    zero   = [nil, 0]

    path = (i - 1).downto(0).zip(scores)
    top = path.find {|x, _| trees[x][j] >= peak }
    top ||= path.last || zero  # in case it returns nil because every tree is lower

    path = (i + 1).upto(height - 1).zip(scores)
    bottom = path.find {|x, _| trees[x][j] >= peak }
    bottom ||= path.last || zero

    path = (j - 1).downto(0).zip(scores)
    left = path.find {|y, _| trees[i][y] >= peak }
    left ||= path.last || zero

    path = (j + 1).upto(width - 1).zip(scores)
    right = path.find {|y, _| trees[i][y] >= peak }
    right ||= path.last || zero

    left[1] * right[1] * top[1] * bottom[1]
  end

  def each(&b)
    (0..width - 1).map do |i|
      (0..height - 1).map do |j|
        b.call i, j
      end
    end
  end
end

def part_one(forest)
  forest.map {|i, j| forest.visible? i, j }.count true
end

def part_two(forest)
  forest.map {|i, j| forest.scenic_score i, j }.max
end

###################################

inp    = STDIN.read
forest = Forest.parse inp

case ARGV[0]
when "one"
  p part_one(forest)
when "two"
  p part_two(forest)
end

