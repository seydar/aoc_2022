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
  attr_accessor :base
  attr_accessor :cache
  attr_accessor :limit

  def initialize(stream)
    @data = WIDTH.times.map { [] } # @data[x][y]
    @time = 0
    @current_rock = nil
    @rocks_seen = -1
    @stream = stream
    @base = 0
    @cache = {}
    @limit = nil

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

    #p "@base: #{@base}"
    #p "top of rocks: #{top_of_rocks}"
    current_rock.tl[0] = [2, WIDTH - current_rock.width].min
    current_rock.tl[1] = top_of_rocks + current_rock.length + 3
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
      use_cache!
      next_rock!
    end

    @time += 1
  end

  def use_cache!
    # Chop off the part of the map that we don't need
    # (save memory)
    new_base = find_base
    if new_base > 0
      @base += new_base
      @data = @data.map {|ys| ys[new_base..-1] }
    end

    # Is there a cycle?
    top_lines = @data.map {|ys| ys[-12..-1] }
    key = [rocks_seen % ROCKS.size, (@time / 2) % @stream.size, top_lines]

    if @cache[key]

      if @cache[key][:state] == :initial
        # Update the cache
        old = @cache[key]
        @cache[key] = {:height => rock_height - old[:height], 
                       :time   => @time - old[:time],
                       :rocks  => rocks_seen - old[:rocks],
                       :state  => :final}

      # :final, so we can take advantage of the tally now
      elsif @cache[key][:rocks] + rocks_seen <= limit
        @base += @cache[key][:height]
        @time += @cache[key][:time]
        @rocks_seen += @cache[key][:rocks]
      end

    else
      @cache[key] = {:height => rock_height, 
                     :time   => @time,
                     :rocks  => rocks_seen, 
                     :state  => :initial}
    end
  end

  def find_base
    data.map {|ys| ys.rindex "#" }.map {|v| v.nil? ? 0 : v }.min
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
    top_of_rocks + 1 + @base
  end
end

def parse_stream(inp)
  inp.strip.split("").map {|d| d == ">" ? :right : :left }
end

def stack_rocks(stream, n)
  map = Map.new stream
  map.limit = n

  until map.rocks_seen == n
    map.move
  end

  map.rock_height
end

def part_one(stream)
  stack_rocks stream, ARGV[1].to_i
end

def part_two(stream)
  stack_rocks stream, 1_000_000_000_000
end

stream = parse_stream STDIN.read

case ARGV[0]
when "one"
  p part_one(stream)
when "two"
  p part_two(stream)
end

