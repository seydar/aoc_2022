#!/usr/bin/env ruby
require 'set'

def parse_map(inp)
  map = {} # adjacency matrix

  matrix = inp.gsub("S", "a")
              .gsub("E", "z")
              .split("\n").map {|l| l.split "" }
  matrix.each.with_index do |row, j|
    row.each.with_index do |elt, i|
      neighbors = [[i + 1, j],
                   [i - 1, j],
                   [i, j + 1],
                   [i, j - 1]]

      # "z" < "z".succ # => false
      # so we have to switch to ord
      map[[i, j]] = neighbors.filter do |x, y|
        y >= 0 && x >= 0 &&
          matrix[y] && matrix[y][x] && matrix[y][x].ord <= elt.ord + 1
      end
    end
  end

  map
end

def path(map, start: nil, finish: nil)
  queued   = []
  queued  << [start, 0]

  visited  = Set.new
  visited << start

  until queued.empty?
    from, steps = queued.shift

    map[from].each do |to|
      next if visited.include? to

      return steps + 1 if to == finish

      queued  << [to, steps + 1]
      visited << to
    end
  end
end

def part_one(inp)
  start, finish = find_all(inp, "S")[0], find_all(inp, "E")[0]
  map = parse_map inp
  path map, :start => start, :finish => finish
end

def part_two(inp)
  starts = find_all(inp, "S") + find_all(inp, "a")
  finish = find_all(inp, "E")[0]

  map = parse_map inp
  starts.map {|start| path map, :start => start, :finish => finish }.compact.min
end

def find_all(inp, val)
  res = []

  matrix = inp.split("\n").map {|l| l.split "" }
  matrix.each.with_index do |row, j|
    row.each.with_index do |elt, i|
      res << [i, j] if elt == val
    end
  end

  res
end

inp = STDIN.read

case ARGV[0]
when "one"
  p part_one(inp)
when "two"
  p part_two(inp)
end
