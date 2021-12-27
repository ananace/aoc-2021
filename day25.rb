#!/bin/env ruby

class Submarine
  def initialize
    @size = { x: 0, y: 0 }
    @data = []
  end

  def add_line(*data)
    @size[:x] = [@size[:x], data.size].max
    @size[:y] += 1

    @data += data
  end

  def step
    moved = []
    moved << step_east
    moved << step_south
    moved.any?(&:itself)
  end

  def puts_map
    last_y = 0
    iterate_map do |_, y, char|
      if y != last_y
        puts
        last_y = y
      end

      print char
    end
    puts
  end

  private

  def step_east
    moved = false
    copy = @data.dup
    iterate_map do |x, y, char|
      next unless char == '>'
      next unless free?(x + 1, y, copy)

      moved = true

      if x + 1 >= @size[:x]
        copy[y * @size[:x]] = '>'
      else
        copy[y * @size[:x] + x + 1] = '>'
      end
      copy[y * @size[:x] + x] = '.'
    end
    @data = copy
    moved
  end

  def step_south
    moved = false
    copy = @data.dup
    iterate_map do |x, y, char|
      next unless char == 'v'
      next unless free?(x, y + 1, copy)

      moved = true

      if y + 1 >= @size[:y]
        copy[x] = 'v'
      else
        copy[(y + 1) * @size[:x] + x] = 'v'
      end

      copy[y * @size[:x] + x] = '.'
    end
    @data = copy
    moved
  end

  def iterate_map(&block)
    @size[:y].times do |y|
      @size[:x].times do |x|
        block.call(x, y, @data[y * @size[:x] + x])
      end
    end
  end

  def free?(x, y, data = @data)
    x = @size[:x] + x if x.negative?
    y = @size[:y] + y if y.negative?
    x -= @size[:x] if x >= @size[:x]
    y -= @size[:y] if y >= @size[:y]

    @data[y * @size[:x] + x] == '.'
  end
end

sub = Submarine.new
open('day25.inp').each_line do |line|
  sub.add_line(*line.strip.chars)
end

# sub.puts_map
# puts
puts 'Calculating...'

moves = 0
loop do
  moves += 1
  break unless sub.step
end

# sub.puts_map
puts "Took #{moves} steps"
