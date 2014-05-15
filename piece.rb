require_relative 'board'
require "debugger"
class Piece
  attr_accessor :board, :color, :pos
  
  def initialize(board,  color, pos)
    @board = board
    @color = color
    @pos = pos
    @board[pos] = self
  end

  def moves
    raise NotImplementedError
  end

  def valid_moves
    #puts "moves before : #{moves}"
    moves.select do |new_pos|
      new_board = board.dup
      new_board.move!(pos, new_pos)
      !new_board.in_check?(color)
    end
  end

  def move_dirs
    raise NotImplementedError
  end

  
  def on_board?(spot)
    #puts "spot is #{spot}"
    (0..7).include?(spot[0]) && (0..7).include?(spot[1])
  end
end

class SliddingPiece < Piece
  def initialize(board,  color, pos)
    super
  end
  
  def moves
    #loop through dirs, one step a time, check : spot empty? if not, spot same side? spot enemy side?
    result = []
    
    row, col = @pos
    move_dirs.each do |pair|
      i = 1
      x, y = pair[0], pair[1]
      new_pos = [row + i * x, col + i * y]
      
      while on_board?(new_pos) && (board[new_pos].nil? ||  board[new_pos].color != @color)
        result << new_pos
        i += 1
        new_pos = [row + i * x, col + i * y]
      end
    end
    result 
  end
end

class SteppingPiece < Piece
  def initialize(board,  color, pos)
    super
  end
  
  def moves
    row = pos[0]
    col = pos[1]
    move_dirs.map {|x, y| [x+row, y+col]}.select  do |new_pos|
      
      on_board?(new_pos) && (board[new_pos].nil? || board[new_pos].color != @color)
    end
  end
end

class Queen < SliddingPiece
  def initialize(board,  color, pos)
    super
  end
  
  def move_dirs
    [[-1, 0], [1, 0], [0, -1], [0, 1],[-1, -1], [-1, 1], [1, -1], [1, 1]]
  end
end

class Rook < SliddingPiece
  def initialize(board,  color, pos)
    super
  end
  
  def move_dirs
    [[-1, 0], [1, 0], [0, -1], [0, 1]]
  end
end

class Bishop < SliddingPiece
  def initialize(board,  color, pos)
    super
  end
  
  def move_dirs
    [[-1, -1], [-1, 1], [1, -1], [1, 1]]
  end
end

class King < SteppingPiece
  def initialize(board,  color, pos)
    super
  end
  
  def move_dirs
    [[-1, 0], [1, 0], [0, -1], [0, 1],[-1, -1], [-1, 1], [1, -1], [1, 1]]
  end
end

class Knight < SteppingPiece
  def initialize(board,  color, pos)
    super
  end
  
  def move_dirs
    [[-1, 2], [-1, -2], [1, 2], [1, -2], [-2, 1], [-2, -1], [2, 1], [2, -1]]
  end
end

class Pawn < Piece
  def initialize(board,  color, pos)
    super
  end
  
  def moves
    
    #among potential moves, if col offset == 0, only move when spot empty, else, only move when enemy there
    row = pos[0]
    col = pos[1]
    result = []
    move_dirs.each do |pair|
      #debugger
      #puts "pair : #{pair}"
      spot = [row + pair[0], col + pair[1]]
      #puts "spot : #{spot}"
      if on_board?(spot)
        #puts "here"
        if pair[1] == 0
          if board[spot].nil?
            result << spot
            #puts "result now: #{result}"
          end
        else
          if board[spot] && board[spot].color != color
            result << spot
          end
        end      
      end
    end
    #puts "result now: #{result}"
    result
  end
  
  def move_dirs
    row = pos[0]
    col = pos[1]
    if color == :black
      if row == 1
        choices = [ [1, -1], [1, 1], [1, 0], [2, 0]]
      else
        choices = [ [1, -1], [1, 1], [1, 0]]
      end
    else
      if row == 6
        choices = [ [-1, -1], [-1, 1],[-1, 0],[-2, 0]]
      else
        choices = [ [-1, -1], [-1, 1],[-1, 0]]
      end
    end 
    choices 
  end
  
end
