#!/bin/env ruby

Vent = Struct.new(:x, :y) do
  def to_s
    "[#{x}, #{y}]"
  end
end
Overlap = Struct.new(:x, :y, :count) do
  def to_s
    "[#{x}, #{y}]=#{count}"
  end
end

class Submarine
  attr_reader :vents

  def initialize
    @vents = []
    @vent_size = Vent.new(0,0)
  end

  def add_vents(from, to, allow_diagonal: false)
    if ((from.x != to.x) && (from.y != to.y))
      unless allow_diagonal
        puts "Skipping diagonal #{from} -> #{to}"
        return
      end
    end

    @vent_size.x = [@vent_size.x, from.x, to.x].max
    @vent_size.y = [@vent_size.y, from.y, to.y].max

    before = @vents.size
    at = from.dup
    if (from.x != to.x || from.y != to.y)
      begin
        @vents << at.dup

        if to.x > at.x
          at.x += 1
        elsif to.x < at.x
          at.x -=1
        end

        if to.y > at.y
          at.y += 1
        elsif to.y < at.y
          at.y -= 1
        end
      end until at == to 
    end
    @vents << at.dup

    puts "Adding vent from #{from} -> #{to}, #{@vents.size - before} vents"

    @vents
  end

  def overlaps(debug: false)
    size = @vent_size.dup
    size.x += 1
    size.y += 1

    puts "Calculating overlap for #{@vents.size} vents, bitmap size #{size}..."
    bitmap = Array.new(size.x * size.y)

    last_update = Time.now

    @vents.each.with_index do |vent, index|
      pos = vent.y * size.y + vent.x
      overlap = bitmap[pos] #.find { |ov| ov.x == vent.x && ov.y == vent.y }
      if overlap
        overlap.count += 1
      else
        overlap = bitmap[pos] = Overlap.new(vent.x, vent.y, 1)
      end

      if Time.now - last_update > 1
        last_update = Time.now
        puts "Calculated #{index + 1}/#{@vents.size} (#{((index+1)/@vents.size) * 100}%)"
      end
    end

    if debug
      (size.y).times do |y_index|
        (size.x).times do |x_index|
          pos = bitmap[y_index * size.y + x_index]
          print pos.nil? ? '.' : pos.count
        end
        puts
      end
    end

    bitmap.reject(&:nil?)
  end
end

sub = Submarine.new
open('day5.inp').each_line do |line|
  from, to = line.strip.split(' -> ')
  sub.add_vents(Vent.new(*from.split(',').map(&:to_i)), Vent.new(*to.split(',').map(&:to_i)), allow_diagonal: true)
end

bitmap = sub.overlaps
max_overlap = bitmap.map(&:count).max
count_overlap = bitmap.count { |ov| ov.count > 1 }
puts "Largest overlap is #{max_overlap}"
puts "Count of overlaps is #{count_overlap}"
