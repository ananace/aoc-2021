#!/bin/env ruby

require 'set'

class Universe
  attr_accessor :players, :rolls, :count

  def initialize(players)
    @players = players
    @rolls = 0
    @count = 1
  end

  def eql?(other)
    return false unless other.is_a? Universe

    players == other.players
  end

  def ==(other)
    eql?(other)
  end

  def hash
    players.hash
  end
end

class Player
  attr_accessor :score, :position

  def initialize(position)
    @position = position
    @score = 0
  end

  def eql?(other)
    return false unless other.is_a? Player

    @position == other.position && @score == other.score
  end

  def ==(other)
    eql?(other)
  end

  def hash
    (@position << 2) ^ @score
  end
end

class Dice
  attr_reader :rolls

  def initialize
    @rolls = 0
  end

  def roll
    @rolls += 1
  end
end

class DeterministicDice < Dice
  def initialize
    super
    @value = 1
  end

  def roll
    super
    ret = @value
    @value += 1
    @value = 1 if @value > 100
    ret
  end
end

class QuantumDice < Dice; end

class Submarine
  attr_accessor :dice
  attr_reader :players, :universes

  def initialize
    @players = []
    @universes = []
    @starts = []
    @dice = DeterministicDice.new
  end

  def add_player(position)
    @starts << position
  end

  def round
    raise NotImplementedError, 'Not going to do this one' if @dice.is_a? QuantumDice

    reset! if @players.empty?
    regular_round
  end

  def play
    reset! if @players.empty?

    if @dice.is_a? QuantumDice
      quantum_game
    else
      regular_round until players.any? { |p| p.score >= 1000 }
    end
  end

  def reset!
    @players.clear
    @players = @starts.map { |s| Player.new(s) }
    @universes.clear
  end

  private

  POSSIBLE = [1, 3, 6, 7, 6, 3, 1].freeze

  def quantum_game
    current = Universe.new(@players)
    current.players.each { |p| p.position -= 1 }
    states = { 0 => Set.new([current]) }
    turns = [current]

    last_report = Time.now

    while turns.any?
      current = turns.shift

      universes = states.fetch(current.rolls + 1) do
        set = Set.new
        states[current.rolls + 1] = set
        set
      end

      pos = current.players.first.position + 2
      POSSIBLE.each do |possibilities|
        pos = (pos + 1) % 10
        side_universe = Universe.new(Marshal.load(Marshal.dump(current.players))).tap do |univ|
          univ.players.first.position = pos
          univ.players.first.score += pos + 1
          univ.count = current.count * possibilities
          univ.rolls = current.rolls + 1
        end

        if side_universe.players.first.score >= 21
          stored = universes.add?(side_universe)
          universes.find { |u| u == side_universe }.count += side_universe.count if stored.nil?

          next
        end

        pos2 = current.players.last.position + 2
        POSSIBLE.each do |possibilities2|
          pos2 = (pos2 + 1) % 10
          side_universe2 = Universe.new(Marshal.load(Marshal.dump(side_universe.players))).tap do |univ|
            univ.players.last.position = pos2
            univ.players.last.score += pos2 + 1
            univ.count = side_universe.count * possibilities2
            univ.rolls = side_universe.rolls
          end

          stored = universes.add?(side_universe2)
          if stored.nil?
            universes.find { |u| u == side_universe2 }.count += side_universe2.count
          elsif side_universe2.players.last.score < 21
            turns << side_universe2
          end
        end
      end

      if Time.now - last_report > 2
        last_report = Time.now
        puts "#{turns.count} universes left to calculate"
      end
    end

    wins = Array.new(2, 0)
    states.each_value do |states|
      states.select { |s| s.players.any? { |p| p.score >= 21 } }.each do |state|
        if state.players.first.score > state.players.last.score
          wins[0] += state.count
        else
          wins[1] += state.count
        end
      end
    end
    wins.max
  end

  def regular_round
    @players.each do |player|
      rolls = 3.times.map { @dice.roll }

      player.position += rolls.sum
      player.position = ((player.position - 1) % 10) + 1
      player.score += player.position

      break if player.score >= 1000
    end
  end
end

sub = Submarine.new
open('day21.inp').each_line do |line|
  sub.add_player line.split.last.to_i
end

sub.play
puts "Result: #{sub.players.map(&:score).min * sub.dice.rolls}"

sub.reset!
sub.dice = QuantumDice.new

results = sub.play

puts "Result: #{results}"
