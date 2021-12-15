#!/bin/env ruby

Point = Struct.new(:x, :y, :risk)
AStarPoint = Struct.new(:x, :y, :g, :h, :parent) do
  def f
    self.g + self.h
  end

  def replace(node)
    g = node.g
    h = node.h
    parent = node.parent
  end
end

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

  def find_path(from = Point.new(0, 0, 0), to = Point.new(@size[:x] - 1, @size[:y] - 1, 0))
    open = [AStarPoint.new(from.x, from.y, 0, 0, nil)]
    closed = []

    until open.empty?
      open.sort! { |a, b| a.f <=> b.f }
      node = open.shift

      closed << node

      if node.x == to.x && node.y == to.y
        open.clear
        break
      end

      possible = []
      possible << AStarPoint.new(node.x - 1, node.y, node.g + get_point(node.x - 1, node.y).risk, estimate_distance(node, to), node) if node.x > 1
      possible << AStarPoint.new(node.x + 1, node.y, node.g + get_point(node.x + 1, node.y).risk, estimate_distance(node, to), node) if node.x < @size[:x] - 1
      possible << AStarPoint.new(node.x, node.y - 1, node.g + get_point(node.x, node.y - 1).risk, estimate_distance(node, to), node) if node.y > 1
      possible << AStarPoint.new(node.x, node.y + 1, node.g + get_point(node.x, node.y + 1).risk, estimate_distance(node, to), node) if node.y < @size[:y] - 1

      possible.each do |successor|
        next if open.find { |n| n.x == successor.x && n.y == successor.y } # && n.f < successor.f }
        next if closed.find { |n| n.x == successor.x && n.y == successor.y && n.f < successor.f }

        open << successor
      end

      # existing = closed.find { |n| n.x == node.x && n.y == node.y }
      # existing&.replace(node)
      
      closed << node
    end

    closed.last
  end

  def get_nodes(endpoint)
    nodes = []
    if endpoint
      at = endpoint
      until at.nil?
        nodes << get_point(at.x, at.y)
        at = at.parent
      end
    end

    nodes.reverse
  end

  def puts_map(endpoint = nil)
    hilight = []
    hilight = get_nodes(endpoint) if endpoint

    @size[:y].times do |y|
      @size[:x].times do |x|
        if hilight.any? { |p| p.x == x && p.y == y }
          print "\e[1;37m"
        end
        print get_point(x, y).risk
        print "\e[0m"
      end
      puts
    end
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

  private

  def estimate_distance(from, to)
    ((from.x - to.x).abs + (from.y - to.y).abs) / 2
  end
end

sub = Submarine.new
open('day15.inp').each_line do |line|
  sub.add_row(*line.strip.chars.map(&:to_i))
end

puts "Finding path on a #{sub.size[:x]}, #{sub.size[:y]} map..."
# sub.puts_map
path = sub.find_path
# puts
# puts "Found path:"
# sub.puts_map(path)

cost = sub.get_nodes(path).map { |n| n.risk }.sum - sub.get_point(0, 0).risk
puts "Result: #{cost}"

sub.expand_map

puts "Finding path on a #{sub.size[:x]}, #{sub.size[:y]} map..."
# sub.puts_map
path = sub.find_path
# puts
# puts "Found path:"
# sub.puts_map(path)

cost = sub.get_nodes(path).map { |n| n.risk }.sum - sub.get_point(0, 0).risk
puts "Result: #{cost}"
