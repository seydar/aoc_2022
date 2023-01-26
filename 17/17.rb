#!/usr/bin/env ruby

class Rock
  attr_accessor :shape
  attr_accessor :tl

  def initialize(shape)
    @shape = shape
    @tl = [0, 0]
  end

  def width
    shape.split("\n")[0].size
  end

  def length
    shape.split("\n").size
  end

  def down;  @tl[1] -= 1; end
  def left;  @tl[0] -= 1; end
  def right; @tl[0] += 1; end

  def all_positions?(&block)
    positions = []
    each {|x, y| positions << block.call(x, y) }
    positions.all?
  end

  def each(&block)
    chars = shape.split("\n").map {|l| l.split "" }

    (0..width - 1).each do |x|
      (0..length - 1).each do |y|
        next if chars[y][x] == '.'

        block.call(@tl[0] + x, @tl[1] - y)
      end
    end
  end
end

class Map
  WIDTH = 7

  ROCKS = "####

.#.
###
.#.

..#
..#
###

#
#
#
#

##
##".split("\n\n")

  attr_accessor :data
  attr_accessor :current_rock
  attr_accessor :time
  attr_accessor :rocks_seen
  attr_accessor :stream

  def initialize(stream)
    @data = WIDTH.times.map { [] } # @data[x][y]
    @time = 0
    @current_rock = nil
    @rocks_seen = -1
    @stream = stream

    next_rock!
  end

  def overlap?
    not current_rock.all_positions? {|x, y| @data[x][y].nil? }
  end

  def out_of_bounds?
    current_rock.tl[0] > WIDTH - current_rock.width ||
      current_rock.tl[0] < 0
  end

  def below_floor?
    # -1 because of 0-based indexing in rock.tl
    current_rock.tl[1] - current_rock.length == -2
  end

  def next_rock!
    @rocks_seen += 1
    @current_rock = Rock.new ROCKS[@rocks_seen % ROCKS.size]

    #p "top of rocks: #{top_of_rocks}"
    #p "current rock height: #{current_rock.length}"
    current_rock.tl[0] = [2, WIDTH - current_rock.width].min
    current_rock.tl[1] = top_of_rocks + current_rock.length + 3
    #p "tl: #{current_rock.tl}"
  end

  def top_of_rocks
    @data.map {|ys| ys.rindex "#" }.compact.max || -1
  end

  def merge_rock!
    current_rock.each do |x, y|
      @data[x][y] = '#'
    end

    # Dynamic arrays, so we need to make them all the same size
    max_y = @data.map {|col| col.size }.max
    @data.each {|col| col[max_y - 1] ||= nil }
  end

  def move
    move_with_jets @stream[(@time / 2) % @stream.size]
    move_down
  end

  def move_with_jets(dir)
    case dir
    when :right
      current_rock.tl[0] = current_rock.tl[0] + 1
    when :left
      current_rock.tl[0] = current_rock.tl[0] - 1
    end

    # order is important here
    undo dir if out_of_bounds? || overlap?

    @time += 1
  end

  def move_down
    current_rock.tl[1] -= 1

    # If overlapping or below the floor, reverse this move
    if overlap? || below_floor?
      undo :down
      merge_rock!
      next_rock!
    end

    @time += 1
  end

  def undo(dir)
    case dir
    when :left
      current_rock.tl[0] += 1
    when :right
      current_rock.tl[0] -= 1
    when :down
      current_rock.tl[1] += 1
    end
  end

  def to_s
    str = ""
    copy = data.map {|r| r.dup }

    merge_rock!
    data.map {|r| r.reverse }.transpose.each do |row|
      str << row.map {|v| v.nil? ? '.' : v }.join
      str << "\n"
    end

    @data = copy # go back to before merging

    str
  end

  def rock_height
    data.map do |column|
      column.map {|v| v.nil? ? " " : v }.join
    end.map {|s| s.strip.size }.max
  end
end

def parse_stream(inp)
  inp.strip.split("").map {|d| d == ">" ? :right : :left }
end

def part_one(stream)
  map = Map.new stream

  until map.rocks_seen == ARGV[1].to_i
    map.move
  end

  map.rock_height
end

stream = parse_stream STDIN.read

case ARGV[0]
when "one"
  p part_one(stream)
when "two"
  p part_two(stream)
end

