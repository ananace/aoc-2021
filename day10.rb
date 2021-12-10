#!/bin/env ruby

Chunk = Struct.new(:opener, :closer)

class Submarine
  OPENERS = [ '(', '[', '{', '<' ].freeze
  CLOSERS = { '(' => ')', '[' => ']', '{' => '}', '<' => '>' }.freeze

  attr_reader :errors, :completions

  def initialize
    @errors = []
    @completions = []
  end

  def parse_line(line)
    # puts "For line #{line}"

    chunks = []
    line.chars.each do |char|
      if OPENERS.include? char
        chunks << Chunk.new(char, CLOSERS[char])
      else
        if char != chunks.last.closer
          @errors << char
          return
        end

        chunks.pop
      end
    end

    completions = []
    chunks.reverse.each do |c|
      completions << c.closer
    end
    @completions << completions
  end
end

SYNTAX_POINTS = { ')' => 3, ']' => 57, '}' => 1197, '>' => 25137 }.freeze
COMPLETION_POINTS = { ')' => 1, ']' => 2, '}' => 3, '>' => 4 }.freeze

sub = Submarine.new
open('day10.inp').each_line do |line|
  sub.parse_line(line.strip)
end

puts "Syntax score: #{sub.errors.map { |c| SYNTAX_POINTS[c] }.sum}"

scores = sub.completions.map do |comp|
  score = 0
  comp.each do |c|
    score *= 5
    score += COMPLETION_POINTS[c]
  end
  score
end
comp_score = scores.sort[scores.size / 2]

puts "Completion score: #{comp_score}"
