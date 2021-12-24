#!/bin/env ruby

class ALU
  attr_reader :vars

  def initialize
    @vars = { x: 0, y: 0, z: 0, w: 0 }

    @input = nil
  end

  def run_program(program, input = nil)
    @vars = { x: 0, y: 0, z: 0, w: 0 }
    @input = input
    program.each { |line| run_line(line) }
    @vars
  end

  def run_line(line)
    return puts @vars if line.strip.empty?

    puts "> #{line}" unless @input
    data = line.strip.split
    send "alu_#{data.shift}".to_sym, *data
  end

  private

  def alu_inp(var)
    if @input
      @vars[var.to_sym] = @input.shift.to_i
    else
      print '< '
      @vars[var.to_sym] = gets.strip.to_i
    end
  end

  def alu_add(var, data)
    data = @vars[data.to_sym] if %w[w x y z].include? data
    data = data.to_i unless data.is_a? Numeric

    @vars[var.to_sym] = @vars[var.to_sym] + data
  end

  def alu_mul(var, data)
    data = @vars[data.to_sym] if %w[w x y z].include? data
    data = data.to_i unless data.is_a? Numeric

    @vars[var.to_sym] = @vars[var.to_sym] * data
  end

  def alu_div(var, data)
    data = @vars[data.to_sym] if %w[w x y z].include? data
    data = data.to_i unless data.is_a? Numeric

    @vars[var.to_sym] = (@vars[var.to_sym] / data).floor
  end

  def alu_mod(var, data)
    data = @vars[data.to_sym] if %w[w x y z].include? data
    data = data.to_i unless data.is_a? Numeric

    @vars[var.to_sym] = @vars[var.to_sym] % data
  end

  def alu_eql(var, data)
    data = @vars[data.to_sym] if %w[w x y z].include? data
    data = data.to_i unless data.is_a? Numeric

    @vars[var.to_sym] = @vars[var.to_sym] == data ? 1 : 0
  end
end

monad = []
alu = ALU.new
open('day24.inp').each_line do |line|
  monad << line.strip
end

puts alu.run_program(monad)

return

test = 1_000_000_000_000_00

largest = 0
latest_report = Time.now
until largest.positive?
  test -= 1
  next if test.to_s.include? '0'

  result = alu.run_program(monad, test.to_s.chars)
  largest = test if result[:z].zero?

  if Time.now - latest_report > 2
    puts "Testing #{test}, largest valid: #{largest}"
    latest_report = Time.now
  end
end
puts "Result: #{largest}"
