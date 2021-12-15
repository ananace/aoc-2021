#!/bin/env ruby

require 'set'

Point = Struct.new(:x, :y, :risk)
PathPoint = Struct.new(:x, :y)

class Submarine
  attr_reader :size

  def initialize
    @size = { x: 0, y: 0}
    @real_size = @size.dup
    @riskmap = []
  end

  def add_row(*row)
    @size[:x] = [@size[:x], row.size].max
    @size[:y] += 1
    @real_size = @size.dup
    @riskmap += row
  end

  def expand_map
    @expanded = true
    @size[:x] *= 5
    @size[:y] *= 5
  end

  CONNECTIONS = [[-1, 0], [1, 0], [0, -1], [0, 1]].freeze
  def find_path(from = PathPoint.new(0, 0), to = PathPoint.new(@size[:x] - 1, @size[:y] - 1))
    costs = { PathPoint.new(from.x, from.y) => 0 }
    visited = Set.new

    found = false
    until found
      point, cost = costs.min_by(&:last)
      visited.add(point)

      CONNECTIONS.map { |x, y| PathPoint.new(point.x + x, point.y + y) }.each do |to_visit|
        next if to_visit.x < 0 || to_visit.y < 0 || to_visit.x >= @size[:x] || to_visit.y >= @size[:y]
        next if visited.include? to_visit

        to_visit_cost = cost + get_risk(to_visit)
        costs[to_visit] = [costs.fetch(to_visit, to_visit_cost), to_visit_cost].min
        found ||= to_visit == to
      end

      costs.delete point
    end

    return costs[to]
  end

  def puts_map
    @size[:y].times do |y|
      @size[:x].times do |x|
        print get_point(x, y).risk
      end
      puts
    end
  end

  def get_risk(point)
    get_point(point.x, point.y).risk
  end

  def get_point(x, y)
    raise 'Outside map' if x < 0 || y < 0 || x >= @size[:x] || y >= @size[:y]
    rx = x
    ry = y

    mod = 0
    while x >= @real_size[:x]
      x -= @real_size[:x]
      mod += 1
    end
    while y >= @real_size[:y]
      y -= @real_size[:y]
      mod += 1
    end

    risk = @riskmap[y * @real_size[:x] + x] + mod
    if risk > 9
      risk -= 9
    end
    Point.new(rx, ry, risk)
  end
end

sub = Submarine.new
open('day15.inp').each_line do |line|
  sub.add_row(*line.strip.chars.map(&:to_i))
end

puts "Finding path on a #{sub.size[:x]}, #{sub.size[:y]} map..."
# sub.puts_map

cost = sub.find_path
puts "Result: #{cost}"

sub.expand_map

puts "Finding path on a #{sub.size[:x]}, #{sub.size[:y]} map..."
# sub.puts_map

cost = sub.find_path
puts "Result: #{cost}"
