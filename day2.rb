#!/bin/env ruby

class Submarine
  attr_reader :position, :depth, :aim

  def initialize
    @position = 0
    @depth = 0
    @aim = 0
  end

  def move_forward(dist)
    @position += dist
    @depth += @aim * dist
  end

  def move_down(dist)
    # @depth += dist # part 1
    @aim += dist
  end

  def move_up(dist)
    # @depth -= dist # part 1
    @aim -= dist
  end
end

sub = Submarine.new
open('day2.inp').each_line do |line|
  op, data = line.split
  sub.send("move_#{op}".to_sym, data.to_i)
end

puts "Position: #{sub.position}, Depth: #{sub.depth}, Aim: #{sub.aim}"
puts "Result: #{sub.position * sub.depth}"
