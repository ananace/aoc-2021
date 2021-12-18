#!/bin/env ruby

class String
  def shift(n = 1)
    d = chars.shift(n).join
    slice!(0, n)
    d
  end
end

class SnailfishNumber
  attr_accessor :value, :left, :right, :parent

  def initialize(value, left = nil, right = nil, parent: nil)
    @value = value
    @left = left
    @right = right
    @parent = parent
  end

  def branch?
    @left || @right
  end

  def leaf?
    @left.nil? && @right.nil?
  end

  def reduce!
    # puts "Reducing #{self}"
    while explode! || split!
    end
  end

  def magnitude
    return value if leaf?

    left.magnitude * 3 + right.magnitude * 2
  end

  def depth
    val = 0
    at = self
    until at.nil?
      val += 1
      at = at.parent
    end
    val
  end

  def +(other)
    new = SnailfishNumber.new(0)
    new.left = Marshal.load(Marshal.dump(self))
    new.left.parent = new
    new.right = Marshal.load(Marshal.dump(other))
    new.right.parent = new
    new.reduce!
    new
  end

  def to_s
    return value.to_s if leaf?

    "[#{left},#{right}]"
  end

  def find_needs_explode(depth = 0)
    e_l = left&.find_needs_explode(depth + 1)
    return e_l if e_l

    e_r = right&.find_needs_explode(depth + 1)
    return e_r if e_r

    return self if left && right && depth >= 4
  end

  def find_needs_split
    return self if value > 9

    left&.find_needs_split || right&.find_needs_split
  end

  private

  def explode!
    to_explode = find_needs_explode
    return false unless to_explode

    to_explode.send :_explode_left
    to_explode.send :_explode_right
    to_explode.value = 0

    true
  end

  def _explode_left
    at = parent
    temp = self

    while at
      break at = at.left if at.left != temp

      temp = at
      at = at.parent
    end

    while at
      break if at.leaf?

      at = at.right
    end

    at.value += @left.value if at
    @left = nil
  end

  def _explode_right
    at = parent
    temp = self

    while at
      break at = at.right if at.right != temp

      temp = at
      at = at.parent
    end

    while at
      break if at.leaf?

      at = at.left
    end

    at.value += @right.value if at
    @right = nil
  end

  def split!
    to_split = find_needs_split
    return false unless to_split

    to_split.left = SnailfishNumber.new (to_split.value / 2.0).floor, parent: to_split
    to_split.right = SnailfishNumber.new (to_split.value / 2.0).ceil, parent: to_split
    to_split.value = 0
    true
  end
end

def parse_snailfish_number(input, parent = nil)
  number = SnailfishNumber.new(0, parent: parent)

  if input.start_with? '['
    raise 'Missing [' unless input.shift == '[' # Remove [

    number.left = parse_snailfish_number(input, number)
    raise 'Missing ,' unless input.shift == ',' # Remove ,

    number.right = parse_snailfish_number(input, number)

    raise 'Missing ]' unless input.shift == ']' # Remove ]
  else
    chars = input.chars.take_while { |c| !['[', ',', ']'].include? c }
    input.shift(chars.size)
    number.value = chars.join.to_i
  end

  number
end

prev = nil
numbers = []
open('day18.inp').each_line do |line|
  break if line.strip.empty?

  number = parse_snailfish_number(line.strip)
  numbers << Marshal.load(Marshal.dump(number))

  if prev
    puts "  #{prev}"
    puts "+ #{number}"

    number = prev + number
    puts "= #{number}"
    puts
  end

  prev = number
end

puts "Final magnitude is #{prev.magnitude}"

puts "Largest possible is #{numbers.product(numbers).reject { |a, b| a == b }.map { |a, b| (a + b).magnitude }.max}"
