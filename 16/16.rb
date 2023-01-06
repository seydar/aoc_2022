#!/usr/bin/env ruby

MAX_TIME = 30

class Valve
  attr_accessor :name
  attr_accessor :flow
  attr_accessor :tunnels

  def initialize(name)
    @name = name
  end

  def inspect
    "#<Valve #{name}: #{flow}>"
  end
end

class Network
  attr_accessor :valves
  attr_accessor :paths

  # undirected graph
  def initialize
    @valves = Hash.new {|h, k| h[k] = Valve.new k }
    @paths = Hash.new {|h, k| h[k] = {} }
  end

  def compute_paths!
    @valves.each {|name, valve| paths_for! valve }
  end

  def paths_for!(valve)
    queue = [valve]
    visited = []
    @paths[valve][valve] = 0

    until queue.empty?
      from = queue.shift

      from.tunnels.each do |to|
        if @paths[valve][to]
          if @paths[valve][from] + 1 < @paths[valve][to]
            @paths[valve][to] = @paths[valve][from] + 1
          end
        else
          @paths[valve][to] = @paths[valve][from] + 1
        end

        unless visited.include? to
          queue   << to
          visited << to
        end
      end
    end
  end

  def add(name, flow, tunnels)
    @valves[name].flow = flow
    @valves[name].tunnels = tunnels.map {|t| @valves[t] }
  end

  def new_max_path
    opened  = []
    current = @valves['AA']
    score = 0

    #order = ["DD", "BB", "JJ", "HH", "EE", "CC"]
    i = 1
    while i <= MAX_TIME
      time_left = MAX_TIME - i

      puts "currently on #{current.inspect} (#{time_left})"

      # What do our best moves look like this iteration?
      # Only look at the current location
      # Don't consider valves with no flow
      # Don't consider valves we've already opened
      options = paths[current].filter {|v| v.flow != 0 }
      options = options.filter {|v| not opened.include?(v) }

      # Given how far away the valves are, which will give us the most ROI?
      options = options.map do |valve, dist|
        gain = (time_left - dist) * valve.flow
        [valve, gain]
      end.to_h
      pp options

      # Go to the best option
      seuraava, gain = options.max_by {|valve, score| score }

      if order ||= nil
        seuraava = (o = order.shift) ? @valves[o] : nil
        gain = options[seuraava]
      end

      if seuraava
        puts "\tnext move: #{seuraava.inspect} (#{paths[current][seuraava]} min away)"

        # Skip forward in time (1 minute for the distance, plus 1 for opening it)
        i += paths[current][seuraava] 
        i += 1

        opened << seuraava
        current = seuraava
        score  += gain
      else
        puts "\tno more moves to make. staying put at #{current.inspect}"
        i += 1
      end
    end

    score
  end

  def max_path
    start = {:at => @valves['AA'],
             :score => 0,
             :time => 1,
             :opened => []}
    queue = [start]
    best = Hash.new {|h, k| h[k] = 0 }

    #order = ["DD", "BB", "JJ", "HH", "EE", "CC"]
    until queue.empty?
      from = queue.shift
      next if from[:time] > MAX_TIME

      time_left = MAX_TIME - from[:time]

      # What do our best moves look like this iteration?
      # Only look at the current location
      # Don't consider valves with no flow
      # Don't consider valves we've already opened
      options = paths[from[:at]].filter {|v| v.flow != 0 }
      options = options.filter {|v| not from[:opened].include?(v) }

      # Given how far away the valves are, which will give us the most ROI?
      options = options.map do |valve, dist|
        gain = (time_left - dist) * valve.flow
        [valve, gain]
      end.to_h

      options.each do |valve, gain|
        sol = {:at => valve,
               :time => from[:time] + paths[from[:at]][valve] + 1,
               :score => from[:score] + gain,
               :opened => from[:opened] + [valve]}
        queue << sol

        key = sol[:opened].sort_by {|v| v.name }
        best[key] = sol[:score] if sol[:score] > best[key]
      end
    end

    best.max_by {|k, v| v }
  end

  def inspect
    "#<Network: #{valves.size} valves>"
  end

  def to_s
    str = ""

    valves.each do |name, v|
      str << "#{name} ={#{v.flow}}=> [#{v.tunnels.map {|t| t.name }.join ", "}]\n"
    end

    str
  end
end

def parse_flows(inp)
  network = Network.new

  inp.split("\n").map do |line|
    flow, tunnels = line.split ";"

    name, flow = flow.split("=")
    name = name.split(" has")[0].split("Valve ")[1]

    flow = flow.to_i

    tunnels = tunnels.split(", ")
    tunnels[0] = tunnels[0][-2..-1]

    network.add name, flow, tunnels 
  end

  network
end

def part_one(flows)
  flows.compute_paths!
  #pp flows.paths.map {|k, paths| [k, paths.filter {|k, d| k.flow != 0 }.map {|k, d| [k, d * k.flow] }.to_h] }
  #              .filter {|k, v| k.flow != 0 }.to_h
  flows.max_path
  #flows.new_max_path
end

flows = parse_flows STDIN.read

case ARGV[0]
when "one"
  p part_one(flows)
when "two"
  p part_two(flows)
end

