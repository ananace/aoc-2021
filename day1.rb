#!/bin/env ruby

class Submarine
  attr_reader :increases, :window_increases

  def initialize
    @increases = 0
    @window_increases = 0
    @window = []
  end

  def add_measurement(depth)
    @increases += 1 if @depth && depth > @depth
    pre_depth = @window.sum if @window.count == 3

    @depth = depth
    @window << depth
    @window.shift if @window.count > 3

    if pre_depth && @window.count == 3 && @window.sum > pre_depth 
      @window_increases += 1
    end
  end
end

sub = Submarine.new
open('day1.inp').each_line do |line|
  sub.add_measurement(line.strip.to_i)
end

puts "Increased #{sub.increases} times."
puts "Increased #{sub.window_increases} times on a 3-count window."
