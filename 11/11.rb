#!/usr/bin/env ruby

class Monkey
  attr_accessor :id
  attr_accessor :items
  attr_accessor :test
  attr_accessor :worry_func
  attr_accessor :next
  attr_accessor :business
  attr_accessor :reducer

  def initialize
    @id = nil
    @items = []
    @test  = nil
    @worry_func = nil
    @next  = []
    @business = 0
    @reducer = nil
  end

  def turn!
    @items.each do |item|
      val = worry_func[item]
      val = reducer[val]

      catcher = val % test == 0 ? @next[0] : @next[1]
      catcher.items << val

      @business += 1
    end

    @items = []
  end

  def inspect
    "#<Monkey:#{id} @items=#{items} @business=#{business} @next=#{@next.map {|m| m.id }}>"
  end
end

def parse_monkeys(str)
  data = str.split "\n\n"
  monkeys = data.map { Monkey.new }
  data.each.with_index do |s, i|
    m = monkeys[i]
    m.id = i

    lines = s.split "\n"

    # Starting items
    nums = lines[1].split(": ")[1].split ", "
    m.items = nums.map(&:to_i)

    # Operation
    # Beware of binding in procs. If you reference $1 in a proc, it's going to
    # forever try to access the $1 in this context, which will be the last value
    # checked (for some reason it was 1 when running test_11.txt)
    op = s.scan(/Operation: new = (.+)$/)[0][0]
    m.worry_func = case op
                   when /[+] (\d+)/
                     operand = $1.to_i
                     proc {|x| x + operand }
                   when /[*] (\d+)/
                     operand = $1.to_i
                     proc {|x| x * operand }
                   when /[*] old/
                     proc {|x| x * x }
                   end

    # Test
    test = s.scan(/Test: divisible by (\d+)/)[0][0]
    m.test = test.to_i

    # Next
    if_true  = s.scan(/If true: .+ (\d+)$/)[0][0]
    if_false = s.scan(/If false: .+ (\d+)$/)[0][0]
    m.next   = [monkeys[if_true.to_i], monkeys[if_false.to_i]]
  end

  monkeys
end

def part_one(monkeys)
  monkeys.each {|m| m.reducer = proc {|x| x / 3 } }

  20.times do
    monkeys.each {|m| m.turn! }
  end

  monkeys.sort_by {|m| - m.business }[0, 2].reduce(1) {|s, v| s * v.business }
end

def part_two(monkeys)
  total = monkeys.map {|m| m.test }.reduce(&:*)
  monkeys.each {|m| m.reducer = proc {|x| x % total } }

  10_000.times do |i|
    monkeys.each {|m| m.turn! }
  end

  monkeys.sort_by {|m| - m.business }[0, 2].reduce(1) {|s, v| s * v.business }
end

monkeys = parse_monkeys STDIN.read

case ARGV[0]
when "one"
  p part_one(monkeys)
when "two"
  p part_two(monkeys)
end

