#!/bin/env ruby

class Range
  def &(other)
    raise ArgumentError unless other.is_a? Range

    return other & self if self.begin > other.begin
    return (other.begin)..(other.begin - 1) if self.end < other.begin

    (other.begin)..([self.end, other.end].min)
  end
end

Grid = Struct.new(:x, :y, :z) do
  def empty?
    x.size.zero? || y.size.zero? || z.size.zero?
  end

  def size
    x.size * y.size * z.size
  end

  def &(other)
    raise ArgumentError unless other.is_a? Grid

    Grid.new(
      x & other.x,
      y & other.y,
      z & other.z
    )
  end
end

FULL_RANGE = (-1_000_000..1_000_000).freeze

class Submarine
  def initialize
    @commands = []
  end

  def turn_on(x_r, y_r, z_r)
    puts "Turning on #{x_r.inspect}, #{y_r.inspect}, #{z_r.inspect}"
    @commands << [:on, Grid.new(x_r, y_r, z_r)]
  end

  def turn_off(x_r, y_r, z_r)
    puts "Turning off #{x_r.inspect}, #{y_r.inspect}, #{z_r.inspect}"
    @commands << [:off, Grid.new(x_r, y_r, z_r)]
  end

  def blocks(constraint = nil)
    grid = Grid.new(constraint, constraint, constraint) if constraint
    grid ||= Grid.new(FULL_RANGE, FULL_RANGE, FULL_RANGE)

    count_blocks(@commands.last, grid)
  end

  private

  def count_blocks(command, inside)
    return 0 if inside.empty?

    if command == @commands.first
      return 0 if command.first == :off

      return (command.last & inside).size
    end

    cmd_ind = @commands.index(command)
    cmd_before = @commands[cmd_ind - 1]

    a = count_blocks(cmd_before, inside)
    if command.first == :on
      b = (command.last & inside).size
      c = count_blocks(cmd_before, command.last & inside)
      a + b - c
    else
      b = count_blocks(cmd_before, command.last & inside)
      a - b
    end
  end
end

sub = Submarine.new
open('day22.inp').each_line do |line|
  action, coords = line.strip.split
  coords = coords.split(',')
  coords.map! { |c| Range.new(*c.split('=').last.split('..').map(&:to_i)) }

  sub.send "turn_#{action}".to_sym, *coords
end

puts "Result: #{sub.blocks(-50..50)}"
puts "Result: #{sub.blocks}"
