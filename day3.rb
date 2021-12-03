#!/bin/env ruby

class Submarine
  attr_accessor :data_width

  def initialize
    @data = []
  end
  
  def add_data(data)
    @data << data
  end

  def gamma_rate
    rate = 0

    (0..data_width).each do |bit|
      rate |= (1 << bit) if num_high(bit) >= @data.size / 2
    end

    rate
  end

  def epsilon_rate
    rate = 0

    (0..data_width).each do |bit|
      rate |= (1 << bit) if num_high(bit) >= @data.size / 2
    end

    rate
  end

  def o2_rating
    possible = @data
    (0..data_width).each do |rev_bit|
      bit = data_width - rev_bit
      n_high, n_low = num_bits(bit, possible)
      high = n_high >= n_low
      possible = possible.select { |data| ((data & (1 << bit)) > 0) == high }
      break if possible.size == 1
    end
    possible.first
  end

  def co2_rating
    possible = @data
    (0..data_width).each do |rev_bit|
      bit = data_width - rev_bit
      n_high, n_low = num_bits(bit, possible)
      high = n_high < n_low
      possible = possible.select { |data| ((data & (1 << bit)) > 0) == high }
      break if possible.size == 1
    end
    possible.first
  end

  private

  def num_bits(bit, set = @data)
    return set.count { |num| (num & (1 << bit)) > 0 }, set.count { |num| (num & (1 << bit)) == 0 }
  end
  def num_high(bit, set = @data)
    num_bits(bit, set).first
  end
end

sub = Submarine.new
open('day3.inp').each_line do |line|
  sub.data_width = line.strip.size - 1
  data = line.to_i(2)
  sub.add_data(data)
end

puts "Gamma rate: #{sub.gamma_rate} (#{sub.gamma_rate.to_s(2)}), Epsilon rate: #{sub.epsilon_rate} (#{sub.epsilon_rate.to_s(2)})"
puts "Result: #{sub.gamma_rate * sub.epsilon_rate}"

puts
puts "O2 rating: #{sub.o2_rating}, CO2 rating: #{sub.co2_rating}"
puts "result: #{sub.o2_rating * sub.co2_rating}"
