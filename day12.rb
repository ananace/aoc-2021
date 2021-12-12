#!/bin/env ruby

class Array
  def delete_last(value)
    reverse!
    ind = index(value)
    delete_at(ind) if ind
    reverse!
  end
end

Cave = Struct.new(:name, :large, :visits) do
  def special?
    %i[start end].include? name
  end

  def large?
    large
  end

  def small?
    !large
  end

  def visit
    self.visits += 1
  end

  def unvisit
    self.visits -= 1
  end
end
Link = Struct.new(:a, :b) do
  def connected_to?(cave)
    a == cave || b == cave
  end

  def opposite(cave)
    return a if b == cave
    b
  end
end

class Submarine
  def initialize
    @caves = []
    @links = []
  end

  def ensure_cave(cave)
    large = cave.to_s.downcase != cave.to_s
    @caves << Cave.new(cave, large, 0) unless @caves.any? { |c| c.name == cave }
  end

  def add_link(a, b)
    @links << Link.new(a, b)
  end

  def find_all_paths(double = false)
    result = []
    mut = Mutex.new
    if double
      smalls = @caves.reject { |c| c.large? || c.special? }
      th = smalls.map do |sm|
        Thread.new do
          puts "Starting #{sm.name}"
          iterate_paths(:start, :end, sm.name, [], [:start], result, mut)
          puts "Finished with #{sm.name}"
        end
      end
      th.each(&:join)
    else
      iterate_paths(:start, :end, nil, [], [:start], result, mut)
    end
    result
  end

  private

  def iterate_paths(at, dest, allowed_double, visited, path_list, result, mut)
    if at == dest
      mut.synchronize do
        result << path_list.dup unless result.include? path_list
      end
      return
    end

    visited << @caves.find { |c| c.name == at }.dup unless visited.any? { |v| v.name == at }
    visited.find { |v| v.name == at }.visit

    available_links = find_links(at).sort { |a, b| a.opposite(at) <=> b.opposite(at) }
    available_links.each do |link|
      target = link.opposite(at)

      if target == allowed_double
        t_c = visited.find { |v| v.name == target }
        if t_c
          next if t_c.visits >= 2
        end
      else
        next if visited.find { |v| v.name == target }&.small?
      end

      path_list << target
      iterate_paths(target, dest, allowed_double, visited.dup, path_list.dup, result, mut)
      path_list.delete_last(target)
    end

    visited.find { |v| v.name == at }.unvisit
  end

  def find_links(cave)
    @links.select { |link| link.connected_to? cave }
  end
end

sub = Submarine.new
open('day12.inp').each_line do |line|
  a, b = line.strip.split('-').map(&:to_sym)
  sub.ensure_cave(a)
  sub.ensure_cave(b)
  sub.add_link(a, b)
end

paths = sub.find_all_paths
puts "Day 1 Result: #{paths.size}"
paths = sub.find_all_paths(true)
puts "Day 2 Result: #{paths.size}"
