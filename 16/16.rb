#!/usr/bin/env ruby

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

  def max_path(max_time=30)
    start = {:at => @valves['AA'],
             :score => 0,
             :time => 1,
             :opened => []}
    queue = [start]
    best = Hash.new {|h, k| h[k] = 0 }

    until queue.empty?
      from = queue.shift
      next if from[:time] > max_time

      time_left = max_time - from[:time]

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

    best
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
  best = flows.max_path 30
  best.max_by {|k, v| v }
end

def part_two(flows)
  best = flows.max_path 26
  pairs = best.to_a.combination(2).filter {|(k1, v1), (k2, v2)| k1 & k2 == [] }
  a, b = pairs.max_by {|(k1, v1), (k2, v2)| v1 + v2 }
  a[1] + b[1]
end

flows = parse_flows STDIN.read
flows.compute_paths!

case ARGV[0]
when "one"
  p part_one(flows)
when "two"
  p part_two(flows)
end

