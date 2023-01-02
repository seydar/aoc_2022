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
    (@x - other.x).abs + (@y - other.y).abs
  end

  def ==(other)
    @x == other.x && @y == other.y
  end

  def to_a
    [@x, @y]
  end
end

def diamond(dist)
  timantti = []
  (0..dist).each do |i|
    (0..(dist - i)).each do |j|
      timantti << [i, j]
      timantti << [-i, -j] if i != 0 && j != 0
      timantti << [-i, j]  if i != 0
      timantti << [i, -j]  if j != 0
    end
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
  attr_accessor :area

  def initialize(x, y, beacon)
    super(x, y)
    @beacon = beacon
  end

  def blocked_area
    return @area if @area

    @area = []
    @area = diamond(distance(@beacon)).map do |x, y|
      [x + @x, y + @y]
    end
  end

  def blocked_area_at(row)
    partial_diamond(distance(@beacon), row - @y).map do |x, y|
      [x + @x, y + @y]
    end
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
    (0..max_y - 1).each do |y|
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
  blocked = map.sensors.map {|s| s.blocked_area_at row }.reduce(&:+).uniq
  blocked = blocked - map.sensors.map {|s| s.to_a } - map.beacons.map {|b| b.to_a }
  blocked.size
end

def part_two(map)
  #map.sensors.map {|s| s.blocked_area }.reduce(&:+)
  [map.min_x, map.max_x, map.min_y, map.max_y]
end

map = parse_input STDIN.read

case ARGV[0]
when "one"
  p part_one(map, (ARGV[1] || 10).to_i)
when "two"
  p part_two(map)
end

