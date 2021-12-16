#!/bin/env ruby

class String
  def shift(n)
    d = chars.shift(n).join
    slice!(0, n)
    d
  end

  # Extended hex parsing, compared to #to_i(16) this keeps starting bits
  def ehex_to_bits
    res = ''
    each_char do |c|
      case c
      when '0'
        res <<= '0000'
      when '1'
        res <<= '0001'
      when '2'
        res <<= '0010'
      when '3'
        res <<= '0011'
      when '4'
        res <<= '0100'
      when '5'
        res <<= '0101'
      when '6'
        res <<= '0110'
      when '7'
        res <<= '0111'
      else
        res <<= c.to_i(16).to_s(2)
      end
    end
    res
  end
end

class Packet
  attr_reader :version, :type, :data

  def initialize(data)
    raise 'too short' if data.size < 7
    parse(data)
  end

  def data_result
    return @data if type == 4 # Literal
    
    data = @data.map(&:data_result)
    case type
    when 0 # Sum
      data.reduce(&:+)
    when 1 # Product
      data.reduce(&:*)
    when 2 # Minimum
      data.min
    when 3 # Maximum
      data.max
    when 5 # Greater than
      data.first > data.last ? 1 : 0
    when 6 # Less than
      data.first < data.last ? 1 : 0
    when 7 # Less than
      data.first == data.last ? 1 : 0
    end
  end

  def sum_version
    vnum = version
    vnum += @data.map(&:sum_version).sum if type != 4
    vnum
  end

  def parse(str)
    @version = str.shift(3).to_i(2)
    @type = str.shift(3).to_i(2)

    value = nil
    case @type
    when 4 # Literal packet
      value = 0
      loop do
        data = str.shift(5)
        flag = data.shift(1).to_i(2)
        num = data.shift(4)

        value <<= 4
        value |= num.to_i(2)

        break if flag.zero?
      end

      @data = value
    else # Operator packet
      ltype = str.shift(1).to_i(2)
      bits = ltype.zero? ? 15 : 11
      data_length = str.shift(bits)
      data_length = data_length.to_i(2)

      packets = []
      if ltype == 0
        block = str.shift(data_length)
        until block.empty?
          packets << Packet.new(block)
        end
      else
        data_length.times do
          packets << Packet.new(str)
        end
      end
      @data = packets
    end
  end

  private

  def read_bits(data, count, reverse: true)
    mask = 0
    count.times do
      mask <<= 1
      mask |= 1
    end

    result = data & mask
    data <<= count

    result = result.to_s(2).reverse.to_i(2) if reverse
    result
  end
end

class Submarine
  attr_reader :packets

  def initialize
    @packets = []
  end

  def add_packets(data)
    @packets << Packet.new(data)
  end
end

sub = Submarine.new
open('day16.inp').each_line do |line|
  data = line.strip.ehex_to_bits
  sub.add_packets(data)
end

sum = sub.packets.map(&:sum_version).sum
puts "Version sum: #{sum}"

sub.packets.each do |p|
  puts "Packet: #{p.sum_version}, result: #{p.data_result}"
end
