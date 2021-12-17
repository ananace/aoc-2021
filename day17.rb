#!/bin/env ruby

Zone = Struct.new(:x, :y) do
  def inside?(x, y)
    self.x.include?(x) && self.y.include?(y)
  end

  def past?(x, y)
    self.x.max < x || self.y.min > y
  end
end

class Probe
  attr_reader :x, :y

  def initialize(xvel, yvel)
    @xvel = xvel
    @yvel = yvel
    @x = 0
    @y = 0
  end

  def simulate
    @x += @xvel
    @y += @yvel
    @xvel += 0 <=> @xvel
    @yvel -= 1
  end

  def inside?(target)
    target.inside?(x, y)
  end
  def past?(target)
    target.past?(x, y)
  end
end

class Submarine
  def initialize
  end

  def define_target(x, y)
    @target = Zone.new(x, y)
  end

  def calculate_highest_trajectory
    maxy = -@target.y.first - 1

    maxy * (maxy + 1) / 2
  end

  def calculate_possibilities
    possibilities = []

    possible_x = (Math.sqrt(@target.x.first * 2).floor)..(@target.x.last)
    possible_y = (@target.y.first)..(-@target.y.first - 1)

    possible_x.each do |x|
      possible_y.each do |y|
        probe = Probe.new(x, y)
        until probe.inside?(@target) || probe.past?(@target)
          probe.simulate
        end
        possibilities << [x, y] if probe.inside?(@target)
      end
    end

    possibilities.size
  end
end

sub = Submarine.new
open('day17.inp').each_line do |line|
  xdata = line.match /x=(-?\d+)\.\.(-?\d+)/
  ydata = line.match /y=(-?\d+)\.\.(-?\d+)/
  sub.define_target((xdata.captures.first.to_i)..(xdata.captures.last.to_i), (ydata.captures.first.to_i)..(ydata.captures.last.to_i))
end

puts "Highest possible: #{sub.calculate_highest_trajectory}"
puts "All potential: #{sub.calculate_possibilities}"
