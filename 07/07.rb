#!/usr/bin/env ruby

class Computer
  attr_accessor :file_system
  attr_accessor :path

  alias_method :fs, :file_system

  def initialize
    @file_system = {"/" => {}}
    @path = []
  end

  def ls(path=@path)
    path.reduce(@file_system) {|dir, p| dir[p] }
  end
  alias_method :cwd, :ls

  # Use the output of `ls` to figure out how big the files are
  def study(lines)
    lines.split("\n").filter {|l| l =~ /\d+ .+/ }.map do |line|
      _, size, fname = line.split /(\d+)\s+/
      cwd[fname] = size.to_i
    end
  end

  def cd(dir)
    case dir
    when ".."; @path.pop
    when "/";  @path    = ["/"]
    else
      cwd[dir] = {}
      @path << dir
    end
  end

  # In another life, memoization here could be useful
  def du(path=["/"])
    dir = path.reduce(@file_system) {|dir, p| dir[p] }

    total = 0
    dir.each do |file, size|
      case size
      when Integer
        total += size
      when Hash
        total += du(path + [file])
      end
    end

    total
  end

  def all_files(&b)
    res  = []
    dirs = [["/"]]

    until dirs.empty?
      path = dirs.pop
      ls(path).each do |n, s|
        if Hash === s
          dirs << (path + [n])
        else
          res  << (path + [n])
        end
      end
    end

    res
  end

  def all_dirs(&b)
    res  = []
    dirs = [["/"]]

    until dirs.empty?
      path = dirs.pop
      ls(path).each do |n, s|
        if Hash === s
          dirs << (path + [n])
          res  << (path + [n])
        end
      end
    end

    res
  end
    
end

def parse_filesystem(cmds)
  computer = Computer.new

  cmds.each do |line|
    case line
    when /^cd/
      computer.cd line.split("cd ").last
    when /^ls/
      computer.study line
    end
  end

  computer
end

def part_one(fs)
  fs.all_dirs.map {|name| fs.du name }
             .filter {|s| s <= 100_000 }
             .sum
end

def part_two(fs)
  disk_size   = 70_000_000
  unused      = disk_size - fs.du
  need_delete = 30_000_000 - unused

  fs.all_dirs.map {|name| [name, fs.du(name)] }
             .sort_by {|n, s| s }
             .find {|n, s| s >= need_delete }[1]
end

lines = STDIN.read.split("$").map(&:strip)
file_system = parse_filesystem lines

case ARGV[0]
when "one"; puts part_one(file_system)
when "two"; p part_two(file_system)
end
