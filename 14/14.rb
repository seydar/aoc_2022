#!/usr/bin/env ruby

Point = Struct.new :x, :y

def range(i, j)
  pair = [i, j].sort
  pair[0]..pair[1]
end

class Source
  POSITION = Point.new 500, 0

  attr_accessor :position

  def initialize(*pos)
    @position = pos
  end

  def fall(map)
    pos  = POSITION
    prev = pos
    stuck, off_screen = false, false

    while pos
      prev       = pos
      below      = Point.new(pos.x    , pos.y + 1)
      down_left  = Point.new(pos.x - 1, pos.y + 1)
      down_right = Point.new(pos.x + 1, pos.y + 1)

      pos = nil
      [down_right, down_left, below].each do |nex|
        case map[nex]
        when :air, :source
          pos        = nex
          stuck      = false
          off_screen = false
        when :rock, :sand
          stuck = true
        when nil
          off_screen = true
          stuck = false
          break
        end
      end
    end

    map[prev] = :sand if stuck

    off_screen ? :off_screen : prev
  end
end

class Map
  attr_accessor :data
  attr_accessor :expand

  def initialize
    @data   = Hash.new {|h, k| h[k] = [] } # {x => [points]}
    @expand = false
    
    # add sand source
    data[Source::POSITION.x][Source::POSITION.y] = :source
  end

  def [](loc)
    unless data.keys.include? loc.x
      if @expand
        max_y = data.values.map {|v| v.size }.max
        data[loc.x] = [:air] * (max_y - 1) + [:rock]
      else
        return
      end
    end

    data[loc.x][loc.y]
  end

  def []=(loc, val)
    data[loc.x][loc.y] = val
  end

  # stretch is [[x,y], ...]
  # B"H for auto-resizing
  def parse_stretch(stretch)
    prev = stretch[0]

    stretch.each do |point|
      range(prev.x, point.x).each do |x|
        range(prev.y, point.y).each do |y|
          data[x][y] = :rock
        end
      end

      prev = point
    end
  end

  def finalize!
    max_y = data.values.map {|v| v.size }.max
    data.values.each {|v| v[max_y - 1] ||= nil }

    data.map do |k, column|
      data[k] = column.map {|e| e == nil ? :air : e }
    end
  end

  def install_floors!
    max_y = data.values.map {|v| v.size }.max

    data.map {|k, col| col[max_y + 1] = :rock }
    finalize!
  end

  def to_s
    str = ""

    max_y = data.values.map {|v| v.size }.max

    (0..max_y - 1).each do |y|
      str << "#{y}\t"
      data.keys.sort.map do |x|

        case data[x][y]
        when :rock
          str << '#'
        when :air
          str << '.'
        when :sand
          str << 'o'
        when :source
          str << '+'
        when nil
          p [x, y, data[x][y]]
          pp data
          raise
        end
      end

      str << "\n"
    end

    str
  end
end

def parse_map(str)
  map = Map.new

  str.split("\n").each do |line|
    stretch = line.split(" -> ").map do |pair|
      pair.split(",").then {|x, y| Point.new x.to_i, y.to_i }
    end

    map.parse_stretch stretch
  end

  map.finalize!

  map
end

def part_one(map)
  source = Source.new

  i = -1
  stoppage = nil
  until stoppage == :off_screen
    stoppage = source.fall map
    i += 1
  end

  puts map
  puts "---------------------------"
  i
end

def part_two(map)
  map.install_floors!
  map.expand = true
  
  source = Source.new
  i = 0
  stoppage = nil
  until stoppage.is_a?(Point) && stoppage == Source::POSITION
    stoppage = source.fall map
    i += 1
  end
  
  #puts map
  puts "---------------------------"
  i
end

map = parse_map STDIN.read

case ARGV[0]
when "one"
  puts part_one(map)
when "two"
  p part_two(map)
end

