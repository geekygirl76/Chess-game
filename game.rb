require_relative 'board'
require_relative 'piece'

class Game
  attr_accessor :rows, :cols

  def initialize
    @rows = {}
    8.downto(1).each do |n|
      @rows[n] = 8 - n
    end

    @cols = {}
    ("a".."h").each do |letter|
      @cols[letter] = letter.ord - 'a'.ord
    end


    @players = [:black , :white]
    @current_player = :white
  end

  def parse(input)
    raw_input = input.split(", ").map {|loc| loc.split("")}
   # p raw_input

    raw_start = raw_input[0]
    raw_finish = raw_input[1]
   # p raw_start, raw_finish

    col, row = raw_start[0], raw_start[1]
    start =[@rows[row.to_i], @cols[col]]
    #p start

    col, row = raw_finish[0], raw_finish[1].to_i
    finish = [@rows[row.to_i], @cols[col]]
    #p finish
    #require'pry';binding.pry
    [start, finish]
  end

  def over?
    @board.checkmate?(:white) || @board.checkmate?(:black)
  end

  def play_turn
    @current_player = ( @current_player==:white ? :black : :white )

  end

  def play
    @board = Board.new
    puts "Move capital pieces if you choose black, otherwise move lowercase pieces."
    puts "Now white color move, put in the start position and the target position, e.g.:
    f2, f3."
    while true
      @board.print_board
      begin
      puts "Now #{@current_player} play!"
      puts "Type your input:"
      input = gets.chomp
      start, end_pos = parse(input)
      @board.move(start, end_pos)
      rescue => e
        puts "Error: #{e}"
        retry
      end
      if self.over?
        if @board.checkmate?(:white)
          puts "Black win!"
        else
          puts "White win!"
        end
        return
      end
      play_turn
    end
  end
end



