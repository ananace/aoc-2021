#!/bin/env ruby

class Submarine
  def initialize
    @crabs = []
  end

  def add_crabs(*crabs)
    @crabs += crabs
  end

  def find_alignment
    range = (@crabs.min..@crabs.max)
    min = @crabs.sum * 10000000

    range.each do |pos|
      fuel = 0
      @crabs.each do |crab|
        diff = (crab - pos).abs
        # fuel += diff # Part 1
        fuel += (0..diff).sum
      end

      min = [min, fuel].min
    end

    min
  end
end

sub = Submarine.new
open('day7.inp').each_line do |line|
  sub.add_crabs *line.strip.split(',').map(&:to_i)
end

minimum = sub.find_alignment
puts "Minimum fuel: #{minimum}"
