require_relative "piece"
require 'debugger'

class Board
  attr_accessor :grid

  def self.empty_grid
    Array.new(8) {Array.new(8)}
  end


  def initialize(pop = true)
    @grid = self.class.empty_grid
    populate if pop
  end

  def populate
    class_list = [Rook, Knight, Bishop, Queen, King, Bishop, Knight, Rook]

    class_list.each_with_index do |classname, i|
      classname.new(self,:black, [0,i])
      classname.new(self,:white, [7,i])
    end

    (0..7).each do |col|
      Pawn.new(self, :white, [6, col])
      Pawn.new(self, :black, [1, col])
    end
  end

  def dup
    new_board = Board.new(false)
    pieces.each do |piece|
      piece.class.new(new_board, piece.color, piece.pos)
    end

    new_board
  end

  def pieces_color(c)
    pieces.select {|p| p.color == c}
  end

  def [](pos)
    @grid[pos[0]][pos[1]]
  end

  def []=(pos, piece)
    @grid[pos[0]][pos[1]] = piece
  end

  def move(start, end_pos)
    #require'pry';binding.pry
    if self[start].nil?
      raise "Invalid move!"
    elsif !self[start].valid_moves.include?(end_pos)
      raise "Invalid move!"
    else
      p = self[start]
      p.pos = end_pos
      self[end_pos]= p
      self[start] = nil
    end
  end

  def move!(start, end_pos)
    p = self[start]
    p.pos = end_pos
    self[end_pos]= p
    self[start] = nil
  end

  def pieces
    @grid.flatten.compact
  end

  def find_king(c)
    #should return the piece
    pieces_color(c).find do |piece|
      piece.is_a?(King)
    end
  end

  def in_check?(c)
    king = find_king(c)
    c2 = (c == :white ? :black : :white)
    pieces_color(c2).any? {|p2| p2.moves.include?(king.pos)}
  end

  def checkmate?(c)
    #debugger
    in_check?(c) && pieces_color(c).all? {|p| p.valid_moves.empty?}
  end

  def print_board
    @grid.each do |row|
      grid_row = ""
      row.each do |piece|
        if piece
          if piece.color == :white

            grid_row += (piece.class.to_s[0..3].downcase + " ")
          else
            grid_row += (piece.class.to_s[0..3].upcase + " ")
          end
        else
          grid_row  += "____ "
        end
      end
      p grid_row
    end
    nil
  end
end

if __FILE__ == $PROGRAM_NAME
  board = Board.new
  board.print_board
  puts


  board.move([6, 5], [5, 5])
  board.print_board
  puts

  board.move([1, 4], [3, 4])
  board.print_board
  puts

  board.move([6, 6], [4, 6])
  board.print_board
  puts

  board.move([0,3], [4, 7])
  board.print_board
  puts

  if board.checkmate?(:white)
    puts "black win!"
  elsif board.checkmate?(:black)
    puts "white win!"
  end
end