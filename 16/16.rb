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

    i = 1
    while i <= MAX_TIME
      time_left = MAX_TIME - i

      # What do our best moves look like this iteration?
      # Only look at the current location
      # Don't consider valves with no flow
      options = paths[current].filter {|v| v.flow != 0 }

      # Given how far away the valves are, which will give us the most ROI?
      options = options.map do |valve, dist|
        gain = (time_left - dist) * valve.flow
        [valve, gain]
      end.to_h

      pp options

      i += 1
    end
  end

  def max_path
    start = @valves['AA']
    solution = {:at     => start,
                :score  => 0,
                :opened => [],
                :path   => [start.name],
                :time   => 1}
    queue = [solution]

    # For every timestamp, there can only be one best answer that has us at a
    # give valve
    best  = {}

    until queue.empty?
      from = queue.shift
      next if from[:time] == MAX_TIME
      #next if best[from[:at]] && from[:score] < best[from[:at]][:score]

      puts "investigating #{from[:at].inspect} with #{from[:score]} (#{from[:path].join ", "})"

      # open it
      if from[:at].flow == 0
        puts "\tnot opening a valve with 0 flow"
      elsif !from[:opened].include?(from[:at])
        puts "\topening valve"
        next_sol = {}
        next_sol[:at] = from[:at]
        next_sol[:time] = from[:time] + 1
        next_sol[:score] = from[:score] + from[:at].flow * (MAX_TIME - from[:time])
        next_sol[:opened] = from[:opened] + [from[:at]]
        next_sol[:path] = from[:path] + [:open]

        if best[next_sol[:at]]
          if next_sol[:score] >= best[next_sol[:at]][:score]
            puts "\tnew best score! #{next_sol[:score]} @ #{next_sol[:time]} min"
            best[next_sol[:at]] = next_sol
          end
        else
          puts "\tnew best score! #{next_sol[:score]} @ #{next_sol[:time]} min"
          best[next_sol[:at]] = next_sol
        end
        
        puts "\tadding to the queue"
        queue << next_sol
      else
        puts "\talready opened"
      end

      # visit each of the other tunnels
      from[:at].tunnels.each do |valve|
        next_sol = from.dup
        next_sol[:at] = valve
        next_sol[:time] += 1
        next_sol[:path] = from[:path] + [valve.name]

        if best[valve]
          if next_sol[:score] > best[valve][:score]
            best[valve] = next_sol
            queue << next_sol
            puts "\tmoving to #{next_sol[:at].inspect}"
          else
            puts "\t#{valve.inspect} no better than a previous visit"
          end
        else
          best[valve] = next_sol
          queue << next_sol
          puts "\tmoving to #{valve.inspect}"
        end
      end
    end

    pp best.map {|k, v| [k, v[:score], v[:time]] }
    best.max_by {|k, sol| sol[:score] }[1]
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
  #flows.max_path[:score]
  flows.new_max_path
end

flows = parse_flows STDIN.read

case ARGV[0]
when "one"
  p part_one(flows)
when "two"
  p part_two(flows)
end

