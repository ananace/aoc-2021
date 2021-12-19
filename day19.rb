#!/bin/env ruby

require 'set'

Point = Struct.new(:x, :y, :z) do
  def +(other)
    raise ArgumentError, 'Not a point' unless other.is_a? Point

    Point.new(x + other.x, y + other.y, z + other.z)
  end

  def -(other)
    raise ArgumentError, 'Not a point' unless other.is_a? Point

    Point.new(x - other.x, y - other.y, z - other.z)
  end

  def self.root
    Point.new(0, 0, 0)
  end
end

class Scanner
  attr_accessor :rotation
  attr_reader :beacons

  def initialize(beacons)
    @beacons = beacons
    @rotation = 0
  end

  def beacons_relative_to(point)
    raise ArgumentError, 'Not a point' unless point.is_a? Point

    transform = proc do |b|
      # Transform heading
      t_b = case @rotation % 6
            when 0
              Point.new(b.x, b.y, b.z)
            when 1
              Point.new(b.x, b.z, b.y)
            when 2
              Point.new(b.y, b.x, b.z)
            when 3
              Point.new(b.y, b.z, b.x)
            when 4
              Point.new(b.z, b.x, b.y)
            when 5
              Point.new(b.z, b.y, b.x)
            end

      # Transform rotation
      case (@rotation / 6) % 8
      when 0
        Point.new(t_b.x, t_b.y, t_b.z)
      when 1
        Point.new(-t_b.x, t_b.y, t_b.z)
      when 2
        Point.new(t_b.x, -t_b.y, t_b.z)
      when 3
        Point.new(-t_b.x, -t_b.y, t_b.z)
      when 4
        Point.new(t_b.x, t_b.y, -t_b.z)
      when 5
        Point.new(-t_b.x, t_b.y, -t_b.z)
      when 6
        Point.new(t_b.x, -t_b.y, -t_b.z)
      when 7
        Point.new(-t_b.x, -t_b.y, -t_b.z)
      end
    end

    @beacons.map do |b|
      point + transform.call(b)
    end
  end
end

class Submarine
  attr_reader :scanners

  def initialize
    @scanners = []
  end

  def add_scanner(beacons)
    @scanners << Scanner.new(beacons)
  end

  def stabilize_readings
    raise 'Already stable' if @scanners.is_a? Hash

    to_stabilize = @scanners.dup
    stabilized = {}

    stabilized[Point.root] = to_stabilize.shift

    puts "Stabilizing #{to_stabilize.size} scanners"

    until to_stabilize.empty?
      point, scanner = stabilize_one(stabilized, to_stabilize)
      stabilized[point] = scanner

      to_stabilize.delete(scanner)

      puts "Stabilized #{point} => #{scanner}, remaining: #{to_stabilize.size}"
    end

    @scanners = stabilized
  end

  def stabile_beacons
    stabilize_readings unless @scanners.is_a? Hash

    beacons = Set.new
    @scanners.each do |point, scanner|
      scanner.beacons_relative_to(point).each { |beacon| beacons << beacon }
    end
    beacons
  end

  private

  def stabilize_one(stabilized, to_stabilize)
    to_stabilize.each do |scanner|
      stabilized.each do |source_point, source|
        source_beacons = source.beacons_relative_to(source_point)

        source_beacons.each do |point|
          48.times do |rotation|
            scanner.rotation = rotation

            scanner.beacons_relative_to(Point.root).each do |testpoint|
              mid = point - testpoint

              test_beacons = scanner.beacons_relative_to(mid)
              next unless (test_beacons & source_beacons).size >= 12 # Base on a large number to be on the safe side

              return mid, scanner
            end
          end
        end
      end
    end

    raise 'Unable to stabilize one'
  end
end

sub = Submarine.new
parse_state = :searching
beacons = []
open('day19.inp').each_line do |line|
  case parse_state
  when :beacons
    if line.strip.empty?
      sub.add_scanner(beacons)
      beacons = []
      parse_state = :searching
    else
      beacons << Point.new(*line.strip.split(',').map(&:to_i))
    end
  when :searching
    parse_state = :beacons if line.include? 'scanner'
  end
end

if beacons.any?
  sub.add_scanner(beacons)
  beacons = []
end

sub.stabilize_readings

puts "Count: #{sub.stabile_beacons.size}"

puts "Greatest distance: #{sub.scanners.keys.product(sub.scanners.keys).reject { |a, b| a == b }.map { |a, b| (a.x - b.x).abs + (a.y - b.y).abs + (a.z - b.z).abs }.max}"
