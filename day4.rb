#!/bin/env ruby

Winner = Struct.new(:number, :board, :winning_number)

class Submarine
  attr_reader :boards, :numbers, :winners

  def initialize
    @boards = []
    @winners = []
  end

  def add_numbers(numbers)
    @numbers = numbers
  end

  def add_board(board)
    puts "Adding board #{boards.size} #{board}"
    @boards << board
  end

  def solve
    numbers.each.with_index do |number, index|
      puts "Number #{index + 1} is #{number}"
      boards.each do |board|
        board.each do |line|
          line.each do |square|
            square[1] = true if square[0] == number
          end
        end

        # Check for solution
        board.each do |line|
          if line.all? { |square| square[1] } && !winners.any? { |win| win.number == boards.index(board) }
            puts "Board #{boards.index(board) + 1} won with number #{number}"
            winners << Winner.new(boards.index(board), Marshal.load(Marshal.dump(board)), number)
          end
        end
        (0..4).each do |col|
          if !winners.any? { |win| win.number == boards.index(board) } && board.all? { |line| line[col][1] }
            puts "Board #{boards.index(board) + 1} won with number #{number}"
            winners << Winner.new(boards.index(board), Marshal.load(Marshal.dump(board)), number)
          end
        end
      end
    end
  end
end

board = []
state = :numbers
sub = Submarine.new
open('day4.inp').each_line do |line|
  next if line.strip.empty?
  puts line

  case state
  when :numbers
    sub.add_numbers(line.strip.split(',').map(&:to_i)) 
    state = :boards
  when :boards
    if board.size == 5
      sub.add_board(board)
      board = []
    end

    board << line.strip.split.map { |c| [c.to_i, false] }
  end
end
sub.add_board(board) if board.size == 5

sub.solve
winner = sub.winners.first
puts "Board #{winner.number + 1} won with the number #{winner.winning_number};"
unmarked = winner.board.sum { |line| line.sum { |square| square[1] ? 0 : square[0] } }
puts "Unmarked sum: #{unmarked}"
puts "Result: #{unmarked * winner.winning_number}"

winner = sub.winners.last
puts "Last winner is #{winner.number + 1} with the number #{winner.winning_number};"
unmarked = winner.board.sum { |line| line.sum { |square| square[1] ? 0 : square[0] } }
puts "Unmarked sum: #{unmarked}"
puts "Result: #{unmarked * winner.winning_number}"

