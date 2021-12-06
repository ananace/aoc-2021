#!/bin/env ruby

class Submarine
  attr_reader :fishes

  def initialize
    @fishes = {
      0 => 0,
      1 => 0,
      2 => 0,
      3 => 0,
      4 => 0,
      5 => 0,
      6 => 0,
      7 => 0,
      8 => 0,
    }
  end

  def add_fishes(*fishes)
    puts "Adding #{fishes.count} lanternfish"

    fishes.each do |num|
      @fishes[num] += 1
    end
  end

  def simulate
    ready = @fishes[0]
    8.times do |ind|
      @fishes[ind] = @fishes[ind + 1]
    end

    @fishes[8] = ready
    @fishes[6] += ready
  end

  def num_fishes
    @fishes.values.sum
  end
end

sub = Submarine.new
puts "Parsing input"
open('day6.inp').each_line do |line|
  sub.add_fishes *line.strip.split(',').map(&:to_i).compact
end

puts "Simulating..."
80.times { sub.simulate }
puts "Fishes: #{sub.num_fishes} after 80 days"

puts "Simulating..."
(256-80).times { sub.simulate }
puts "Fishes: #{sub.num_fishes} after 256 days"
