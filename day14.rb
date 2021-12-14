#!/bin/env ruby

Rule = Struct.new(:pair, :element)
Count = Struct.new(:value) do
  def add(amount)
    amount = amount.value if amount.is_a? Count
    self.value += amount
  end
end

class Submarine
  def initialize
    @rules = {}
  end

  def set_template(template)
    @template = template
  end

  def add_rule(pair, element)
    @rules[pair] = Rule.new(pair, element)
  end

  def polymerize(steps = 1)
    puts "Polymerizing #{@template} for #{steps} steps"

    molecules = {}
    for i in 0..(@template.size - 2) do
      pair = @template[i, 2]

      (molecules[pair] ||= Count.new(0)).add(1)
    end

    steps.times do |step|
      polymers = {}
      molecules.each do |mol, amnt|
        res = mol.dup
        res.insert(1, @rules[mol].element)

        (polymers[res[0,2]] ||= Count.new(0)).add(amnt)
        (polymers[res[1,2]] ||= Count.new(0)).add(amnt)
      end
      molecules = polymers
    end

    # Convert polymers into element counts
    # Only counts the first element in each polymer as they're created by pair-matching
    # Adds one to the last element in the template, as that one would be missed otherwise
    res = {}
    molecules.each do |mol, amnt|
      res[mol[0]] ||= 0
      res[mol[0]] += amnt.value
    end
    res[@template.chars.last] += 1

    res
  end
end

sub = Submarine.new
parse_state = :template
open('day14.inp').each_line do |line|
  case parse_state
  when :template
    if line.strip.empty?
      parse_state = :rules
    else
      sub.set_template(line.strip)
    end
  when :rules
    pair, element = line.strip.split(' -> ')
    sub.add_rule(pair, element)
  end
end

counts = sub.polymerize(10)
puts "Result: #{counts.values.max - counts.values.min}"

counts = sub.polymerize(40)
puts "Part 2 Result: #{counts.values.max - counts.values.min}"
