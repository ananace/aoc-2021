#!/bin/env ruby


class Submarine
  attr_reader :flashes, :flashes_this_step

  def initialize
    @size = { x: 0, y: 0 }
    @octopodes = []
    @flashes = 0
    @flashes_this_step = 0
  end

  def add_octopodes(*octopodes)
    @size[:x] = octopodes.size
    @size[:y] += 1
    @octopodes += octopodes
  end

  def simulate
    flashed = []
    @octopodes.size.times do |i|
      @octopodes[i] += 1
    end


    @size[:y].times do |y|
      @size[:x].times do |x|
        next unless energy_at(x, y) > 9

        flood_ping(flashed, x, y)
      end
    end
    flashed.each do |f|
      @octopodes[f] = 0
    end
    @flashes_this_step = flashed.size
    @flashes += flashed.size
  end

  def display
    @size[:y].times do |y|
      @size[:x].times do |x|
        if energy_at(x, y) == 0
          print "\e[1;37m"
        end
        e = energy_at(x, y)
        print e
        print "\e[0m"
      end
      puts
    end
  end

  private

  def energy_at(x, y)
    return nil if x < 0 || y < 0 || x >= @size[:x] || y >= @size[:y]

    @octopodes[y * @size[:x] + x]
  end

  def increase_at(x, y)
    return nil if x < 0 || y < 0 || x >= @size[:x] || y >= @size[:y]

    @octopodes[y * @size[:x] + x] += 1
  end

  def flood_ping(flashed, x, y)
    energy = energy_at(x, y)
    return if energy.nil?

    increase_at(x, y)

    return if energy < 9
    return if flashed.include?(y * @size[:x] + x)

    flashed << y * @size[:x] + x

    flood_ping(flashed, x - 1, y - 1)
    flood_ping(flashed, x + 0, y - 1)
    flood_ping(flashed, x + 1, y - 1)
    flood_ping(flashed, x + 1, y + 0)
    flood_ping(flashed, x + 1, y + 1)
    flood_ping(flashed, x + 0, y + 1)
    flood_ping(flashed, x - 1, y + 1)
    flood_ping(flashed, x - 1, y + 0)
  end
end

sub = Submarine.new
open('day11.inp').each_line do |line|
  sub.add_octopodes(*line.strip.chars.map(&:to_i))
end

puts "Input:"
sub.display
puts

100.times do |step|
  sub.simulate
end

puts "Total flashes after 100 steps: #{sub.flashes}"

step = 100
loop do
  sub.simulate
  step += 1

  break if sub.flashes_this_step == 100
end

puts "Step that flashes all: #{step}"
