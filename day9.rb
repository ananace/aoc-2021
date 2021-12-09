#!/bin/env ruby

Point = Struct.new(:x, :y, :depth)

class Submarine
  def initialize
    @size = { x: 0, y: 0 }
    @heightmap = []
  end

  def add_line(line)
    @size[:x] = line.size
    @size[:y] += 1
    @heightmap += line.chars.map(&:to_i)
  end

  def find_lowest(display: false)
    puts "Searching map of size #{@size}"

    low = []
    @size[:y].times do |y|
      @size[:x].times do |x|
        at = at_point(x, y)

        if (x > 0 && at_point(x - 1, y) <= at) \
          || (y > 0 && at_point(x, y - 1) <= at) \
          || (x < @size[:x] - 1 && at_point(x + 1, y) <= at) \
          || (y < @size[:y] - 1 && at_point(x, y + 1) <= at)
        else
          low << Point.new(x, y, at)
        end
      end
    end

    puts "Calculating basins..."
    basins = []
    low.each do |point|
      basin = []
      flood_fill(basin, point.x, point.y)
      basins << basin
    end

    puts "Found #{basins.count} basins"

    if display
      @size[:y].times do |y|
        @size[:x].times do |x|
          at = at_point(x, y)

          if low.any? { |l| l.x == x && l.y == y }
            print "\e[1;31m"
          elsif basins.any? { |b| b.any? { |p| p.x == x && p.y == y } }
            print "\e[1;32m"
          end
          print at
          print "\e[0m"
        end
        puts
      end
    end

    return low, basins
  end

  private
  
  def flood_fill(basin, x, y)
    return if (x < 0 || x >= @size[:x] || y < 0 || y >= @size[:y])
    return if basin.any? { |p| p[:x] == x && p[:y] == y }

    value = at_point(x, y)
    return if value == 9

    basin << Point.new(x, y, at_point(x, y))
    flood_fill(basin, x - 1, y)
    flood_fill(basin, x + 1, y)
    flood_fill(basin, x, y - 1)
    flood_fill(basin, x, y + 1)
  end

  def at_point(x, y)
    @heightmap[y * @size[:x] + x]
  end
end

sub = Submarine.new
open('day9.inp').each_line do |line|
  sub.add_line(line.strip)
end

lowest, basins = sub.find_lowest
puts "Result: #{lowest.map { |p| p.depth.succ }.sum}"
puts "Basins: #{basins.map { |b| b.size }.sort.reverse.take(3).reduce(1, :*)}"
