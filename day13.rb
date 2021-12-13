#!/bin/env ruby

Point = Struct.new(:x, :y)
Fold = Struct.new(:line, :axis)

class Submarine
  def initialize
    @size = { x: 0, y: 0 }
    @dots = []
    @folds = []
  end

  def add_dot(x, y)
    @size[:x] = [x + 1, @size[:x]].max
    @size[:y] = [y + 1, @size[:y]].max
    @dots << Point.new(x, y)
  end

  def add_fold(line, axis)
    @folds << Fold.new(line, axis)
  end

  def execute_folds
    size = @size.dup
    paper = Array.new(size[:x] * size[:y], nil)
    @dots.each { |d| paper[d.y * @size[:x] + d.x] = true }

    puts "Paper: #{size} (#{paper.count(&:itself)})"
    puts_paper(paper, size)

    @folds.each do |fold|
      puts "Folding along #{fold.axis} #{fold.line}"
      if fold.axis == :y
        for y in ((fold.line + 1)..(size[:y] - 1)) do
          size[:x].times do |x|
            target_y = fold.line - (y - fold.line)

            if paper[y * @size[:x] + x]
              paper[target_y * @size[:x] + x] = true
            end
            paper[y * @size[:x] + x] = nil
          end
        end

        size[:y] = fold.line
      else
        size[:y].times do |y|
          for x in ((fold.line + 1)..(size[:x] - 1)) do
            target_x = fold.line - (x - fold.line)

            if paper[y * @size[:x] + x]
              paper[y * @size[:x] + target_x] = true
            end
            paper[y * @size[:x] + x] = nil
          end
        end
        size[:x] = fold.line
      end

      puts_paper(paper, size)
    end
  end

  private

  def puts_paper(paper, size)
    return if size[:x] > 88 || size[:y] > 20

    size[:y].times do |y|
      size[:x].times do |x|
        if paper[y * @size[:x] + x]
          print '#'
        else
          print '.'
        end
      end
      puts
    end
    puts
  end
end

sub = Submarine.new
parse_state = :dots
open('day13.inp').each_line do |line|
  case parse_state
  when :dots
    if line.strip.empty?
      parse_state = :folds
    else
      sub.add_dot(*line.strip.split(',').map(&:to_i))
    end
  when :folds
    folddata = line.match(/(\w+)=(\d+)/)
    sub.add_fold(folddata.captures.last.to_i, folddata.captures.first.to_sym)
  end
end

sub.execute_folds

