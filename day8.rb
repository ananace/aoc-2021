#!/bin/env ruby

SegmentData = Struct.new(:patterns, :output) do
  def translated_output
    d_069 = patterns.select { |p| p.size == 6 }
    d_235 = patterns.select { |p| p.size == 5 }
    d_1   = patterns.select { |p| p.size == 2 }.first
    d_4   = patterns.select { |p| p.size == 4 }.first
    d_9   = d_069.select { |p| (d_1.chars - p.chars).empty? }.select { |p| (d_4.chars - p.chars).empty? }.first
    d_25  = d_235.select { |p| (d_1.chars - p.chars).any? }

    digits = {
      d_069.select { |p| (d_1.chars - p.chars).empty? }.select { |p| (d_4.chars - p.chars).any? }.first => '0',
      d_1 => '1',
      d_25.select { |p| (p.chars - d_9.chars).any? }.first => '2',
      d_235.select { |p| (d_1.chars - p.chars).empty? }.first => '3',
      d_4 => '4',
      d_25.select { |p| (p.chars - d_9.chars).empty? }.first => '5',
      d_069.select { |p| (d_1.chars - p.chars).any? }.first => '6',
      patterns.select { |p| p.size == 3 }.first => '7',
      patterns.select { |p| p.size == 7 }.first => '8',
      d_9 => '9'
    }

    translated = output.map { |digit| digits[digit] }.join
    if translated.size != 4
      puts "Something went wrong for line #{patterns.join' '} | #{output.join ' '}"
      puts
      puts "Estimations:"
      puts "069 => #{d_069}"
      puts "235 => #{d_235}"
      puts "1   => #{d_1}"
      puts "4   => #{d_4}"
      puts "8   => #{d_8}"
      puts "9   => #{d_9}"
      puts "25  => #{d_25}"
      puts
      puts "Mapping: #{digits}"
      puts "Input: #{output}"
      puts
      puts "Translated: #{translated}"
      raise 'Christmas is ruined!'
    end
    translated.to_i
  end
end

class Submarine
  attr_reader :lines

  def initialize
    @lines = []
  end

  def add_line(patterns, output)
    @lines << SegmentData.new(patterns, output)
  end

  def unique_digits
    @lines.map(&:output).flatten.count { |d| [2, 4, 3, 7].include? d.size }
  end

  def translated_lines
    @lines.map(&:translated_output)
  end
end

sub = Submarine.new
open('day8.inp').each_line do |line|
  input, output = line.strip.split('|')
  sub.add_line input.split(' ').map { |s| s.chars.sort.join }, output.split(' ').map { |s| s.chars.sort.join }
end

puts "Unique digits: #{sub.unique_digits}"
puts "Result is #{sub.translated_lines.sum}"
