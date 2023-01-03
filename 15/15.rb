#!/usr/bin/env ruby

class Point
  attr_accessor :x
  attr_accessor :y

  def initialize(x, y)
    @x = x
    @y = y
  end

  # manhattan distance
  def distance(other)
    if other.is_a? Array
      (@x - other[0]).abs + (@y - other[1]).abs
    else
      (@x - other.x).abs + (@y - other.y).abs
    end
  end

  def ==(other)
    @x == other.x && @y == other.y
  end

  def to_a
    [@x, @y]
  end
end

def in_range(rng, i, j)
  return true unless rng
  [i, j].all? {|a| a >= rng[0] && a <= rng[1] }
end

def border(dist, offset: [0, 0], restrict: nil)
  x, y = *offset
  dist += 1
  timantti = []
  (0..dist).each do |i|
    j = dist - i
    timantti << [x + i, y + j] if in_range(restrict, x + i, y + j)
    timantti << [x - i, y - j] if i != 0 && j != 0 && in_range(restrict, x - i, y - j)
    timantti << [x - i, y + j] if i != 0 && in_range(restrict, x - i, y + j)
    timantti << [x + i, y - j] if j != 0 && in_range(restrict, x + i, y - j)
  end

  timantti
end

def partial_diamond(dist, row)
  timantti = []
  (0..dist - row.abs).each do |i|
    timantti << [i, row]
    timantti << [-i, row] if i != 0
  end

  timantti
end

class Sensor < Point
  attr_accessor :beacon
  attr_accessor :span

  def initialize(x, y, beacon)
    super(x, y)
    @beacon = beacon
    @span = distance @beacon
  end

  def blocked_area_at(row)
    partial_diamond(span, row - @y).map do |x, y|
      [x + @x, y + @y]
    end
  end

  def border_points(restrict: nil)
    border span, :offset => [@x, @y], :restrict => restrict
  end
end

class Beacon < Point
end

class Map
  attr_accessor :data
  attr_accessor :sensors
  attr_accessor :beacons

  def initialize
    @sensors = []
    @beacons = []
    @data    = Hash.new {|h, k| h[k] = {} }
  end

  def add_sensor(pt)
    @sensors << pt
    @data[pt.x][pt.y] = :sensor
  end

  def add_beacon(pt)
    @beacons << pt
    @data[pt.x][pt.y] = :beacon
  end

  def max_x; data.keys.max; end
  def min_x; data.keys.min; end
  def max_y; data.values.map {|v| v.keys.max }.max; end
  def min_y; data.values.map {|v| v.keys.min }.min; end

  def to_s
    str = ""
    (0..max_y).each do |y|
      str << "#{y}:\t"
      (min_x..max_x).each do |x|
        case data[x][y]
        when nil
          str << '.'
        when :sensor
          str << 'S'
        when :beacon
          str << 'B'
        end
      end
      str << "\n"
    end

    str
  end
end

def parse_input(txt)
  map = Map.new

  pairs = txt.split("\n").map do |line|
    line.split(": closest beacon is at x=").then do |sensor, beacon|
      s = sensor.split("Sensor at x=")[1].split(", y=").map(&:to_i)
      b = beacon.split(", y=").map(&:to_i)
      [s, b]
    end
  end

  pairs.each do |sensor, beacon|
    b = Beacon.new(beacon[0], beacon[1])
    s = Sensor.new(sensor[0], sensor[1], b)
    map.add_sensor s
    map.add_beacon b
  end

  map
end

def part_one(map, row)
  #puts map
  #puts "****************************"

  blocked = map.sensors.map {|s| s.blocked_area_at row }.reduce(&:+).uniq
  blocked = blocked - map.sensors.map {|s| s.to_a } - map.beacons.map {|b| b.to_a }
  blocked.size
end

def part_two(map)
  min_x, max_x = map.sensors.map {|s| s.x }.min, map.sensors.map {|s| s.x }.max
  min_y, max_y = map.sensors.map {|s| s.y }.min, map.sensors.map {|s| s.y }.max

  ret = nil
  map.sensors.map {|s| s.border_points(:restrict => [0, 4_000_000]) }.flatten(1).each do |pt|
    too_close = map.sensors.any? do |s|
      s.distance(pt) <= s.span
    end

    (ret = pt) and break unless too_close
  end

  ret[0] * 4_000_000 + ret[1]
end

map = parse_input STDIN.read

case ARGV[0]
when "one"
  p part_one(map, (ARGV[1] || 10).to_i)
when "two"
  p part_two(map)
end

