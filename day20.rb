#!/bin/env ruby

class Submarine
  def initialize
    @input_size = { x: 0, y: 0 }
    @algorithm = nil
    @outside = false # All images start with dark background

    @image = []
  end

  def specify_algorithm(data)
    @algorithm = data.chars.map { |c| c == '#' }
  end

  def add_image_line(*data)
    @input_size[:x] = [@input_size[:x], data.size].max
    @input_size[:y] += 1

    @image += data.map { |c| c == '#' }
  end

  def enhance!
    puts 'Enhancing image...'

    output = []
    output_size = @input_size.dup
    output_size[:x] += 2
    output_size[:y] += 2

    offset = { x: -1, y: -1 }

    # All data outside the image itself is empty so can be ignored

    output_size[:y].times do |y|
      output_size[:x].times do |x|
        output << get_result(x, y, offset)
      end
    end

    # Ensure background is the right colour (@algorithm[0] if dark, @algorithm[511] if light)
    @outside = if !@outside
                 @algorithm.first
               else
                 @algorithm.last
               end

    @image = output
    @input_size = output_size
  end

  def puts_image
    @input_size[:y].times do |y|
      @input_size[:x].times do |x|
        print lit?(x, y) ? '#' : '.'
      end
      puts
    end
  end

  def count_lit
    @image.count(&:itself)
  end

  private

  def get_result(x, y, offset)
    data = []

    dx = x + offset[:x]
    dy = y + offset[:y]

    ((dy - 1)..(dy + 1)).each do |y|
      ((dx - 1)..(dx + 1)).each do |x|
        data << lit?(x, y) ? '1' : '0'
      end
    end

    num = data.map { |b| b ? '1' : '0' }.join.to_i(2)
    @algorithm[num]
  end

  def lit?(x, y)
    return @outside if x < 0 || y < 0 || x >= @input_size[:x] || y >= @input_size[:y]

    @image[y * @input_size[:x] + x]
  end
end

sub = Submarine.new
parse_state = :algorithm
open('day20.inp').each_line do |line|
  if parse_state == :algorithm
    sub.specify_algorithm(line.strip)
    parse_state = :image
  else
    next if line.strip.empty?

    sub.add_image_line(*line.strip.chars)
  end
end

sub.puts_image
puts "#{sub.count_lit} lit"
puts

sub.enhance!
sub.enhance!

sub.puts_image
puts "#{sub.count_lit} lit"
puts

puts 'Enhancing 48 more times...'
48.times { sub.enhance! }
puts "#{sub.count_lit} lit"
