require 'debugger'
class Piece
  attr_accessor :board, :color, :pos
  
  def initialize(board,  color, pos)
    @board = board
    @color = color
    @pos = pos
    @board.grid[@pos] = self
    
  

  end

  def moves
    #general moves: only move to an empty spot or capture opponant's piece
    #working fine
    result = []
    (0..7).each do |r|
      (0..7).each do |c|
        if @board.grid[r][c].nil? || @board.grid[r][c].color != @color
          result << [r, c]
        end
      end
    end
    result
  end

  

  def valid_moves
    #dup board
    #for all position in next_moves, move, if board.in_check for the piece's color, reject that position from next_moves
    #return the new next_moves as valid_moves
    

    moves.select do |new_pos|
      new_board = board.dup
      new_board.move(pos, new_pos)
      !new_board.in_check?(color)
       
    end
  end

  def move_dirs
    raise NotImplementedError
  end

end

class SlidingPiece < Piece
  def initialize(board, name, color, row, col)
    super
  end

  def moves
    result = []
    @dirs.each do |offset|
      n= 1
      new_row = offset[0] * n + @row
      new_col = offset[1] * n + @col

      while ((0..7).include?(new_row) && (0..7).include?(new_col))
        result << [new_row, new_col] 

        n+=1
        new_row = offset[0] * n + @row
        new_col = offset[1] * n + @col
      end
    end
    result.select {|pos| super.include?(pos)}
  end

  def next_moves
    #debugger

    #moves = super
    #puts "Here: #{moves}"
    
    choices = moves
    choices.reject! do |target|
      should_delete = false
      row = target[0]
      col = target[1]
      if @row == row
        col_diff = (col - @col).abs
        s = [col, @col].min
        e = [col, @col].max
        (s+1...e).each do |col|
          if @board.grid[row][col] 
            should_delete = true
            break
          end
        end
      elsif @col == col
        row_diff = (row - @row).abs
        s = [row, @row].min
        e = [row, @row].max
        (s+1...e).each do |row|
          if @board.grid[row][col] 
            should_delete = true
            break
          end
        end
      else
        s_row = [row, @row].min

        e_row = [row, @row].max

        s_col = [col, @col].min

        e_col = [col, @col].max
        #puts "col: #{s_col} #{e_col}"
        #puts "Now checking #{target}"
        # p (s_row + 1...e_row).to_a
#         p (s_col + 1...s_col).to_a
        (s_row + 1...e_row).each do |row|
          #puts "ROW: #{row}"
          (s_col + 1...e_col).each do |col|
            # puts "danger!!!"
#             p [row, col]

            if !@board.grid[row][col].nil?
              #p @board.grid[row][col].name
              should_delete = true
              break
            end
          end
        end
      end
      should_delete
    end


    choices
  end

end


class SteppingPiece < Piece
  def initialize(board, name, color, row, col)
    super
  end

  def moves
    result =[]
    @dirs.each do |offset|
      if (0..7).include?(@row + offset[0]) && (0..7).include?(@col + offset[1])
        result << [@row + offset[0], @col + offset[1]]
      end
    end
    result.select {|pos| super.include?(pos)}
  end


end

class Knight < SteppingPiece
  def initialize(board, name, color, row, col)
    super
  end

  def move_dirs
    [[-1, 2], [-1, -2], [1, 2], [1, -2], [-2, 1], [-2, -1], [2, 1], [2, -1]]
  end
end

class King < SteppingPiece
  def initialize(board, name, color, row, col)
    super
  end

  def move_dirs
    [[-1, 0], [1, 0], [0, -1], [0, 1],[-1, -1], [-1, 1], [1, -1], [1, 1]]
  end
end

class Pawn < Piece
  def initialize(board, name, color, row, col)
    super
  end

  def moves
    #move forward one at a time
    #starting place can move forward 2
    #if enemy at diagnal, can move in that direction one step
    result = []
    if @color == 'white'
      if @row == 6
        result += [[@row-1, @col], [@row-2, @col]]

      else
        result += [[@row-1, @col]]
      end
    else
      if @row == 1
        result += [[@row+1, @col], [@row+2, @col]]
      else
        result += [[@row+1, @col]]
      end
    end
    result.reject! {|r, c| @board.grid[r][c]}
    result
  end

  def attack_moves
    result =[]
    if @color == 'white'
      result << [@row - 1, @col - 1]
      result << [@row - 1, @col + 1]
    else
      result << [@row + 1, @col - 1]
      result << [@row + 1, @col + 1]
    end
    result
  end

  def next_moves
    potential_moves = moves + attack_moves
    potential_moves.reject! do |target|
      should_delete = false

      r, c = target[0], target[1]
      if (attack_moves.include?(target) && !@board.grid[r][c]) ||
         (attack_moves.include?(target) && !@board.grid[r][c].color == @color)
         should_delete = true
       elsif moves.include?(target) && (r - @row).abs == 2 && @board.grid[(r + @row) / 2][c]
         should_delete = true
       end
       should_delete
    end
    potential_moves
  end

end

class Bishop < SlidingPiece
  def initialize(board, name, color, row, col)
    super
  end

  def move_dirs
    dirs [[-1, -1], [-1, 1], [1, -1], [1, 1]]
  end

  def moves
    super
  end
end

class Rook < SlidingPiece


  def initialize(board, name, color, row, col)
    super
  end

  def move_dirs
    @dirs = [[-1, 0], [1, 0], [0, -1], [0, 1]]
  end

  def moves
    super
  end
end

class Queen < SlidingPiece

  def initialize(board, name, color, row, col)
    super
  end

  def move_dirs
    @dirs = [[-1, 0], [1, 0], [0, -1], [0, 1],[-1, -1], [-1, 1], [1, -1], [1, 1]]
  end

  def moves
    super
  end

  def next_moves
    super
  end
end

class Board
  attr_accessor :grid

  def self.first_grid
    
    #make an array [Rook,Queen,...]
    
    first_grid = {}

    first_grid[[0, 3]] = ['Q', 'black']
    first_grid[[0, 4]] = ['K', 'black']
    first_grid[[0, 2]] = ['B', 'black']
    first_grid[[0, 5]] = ['B', 'black']
    first_grid[[0, 1]] = ['N', 'black']
    first_grid[[0, 6]] = ['N', 'black']
    first_grid[[0, 0]] = ['R', 'black']
    first_grid[[0, 7]] = ['R', 'black']

    first_grid[[7, 3]] = ['q', 'white']
    first_grid[[7, 4]] = ['k', 'white']
    first_grid[[7, 2]] = ['b', 'white']
    first_grid[[7, 5]] = ['b', 'white']
    first_grid[[7, 1]] = ['n', 'white']
    first_grid[[7, 6]] = ['n', 'white']
    first_grid[[7, 0]] = ['r', 'white']
    first_grid[[7, 7]] = ['r', 'white']

    (0..7).each do |col|
      first_grid[[6, col]] = ['P', 'white']
      first_grid[[1, col]] = ['p', 'black']
    end
    first_grid
  end

  def initialize(hash = self.class.first_grid)
    @grid = Array.new(8) {Array.new(8)}

    hash.each do |key, value|
      if value[0].downcase == 'q'
        Queen.new(self, value[0], value[1], key[0], key[1])
      elsif value[0].downcase == 'k'
        King.new(self, value[0], value[1], key[0], key[1])
      elsif value[0].downcase == 'n'
        Knight.new(self, value[0], value[1], key[0], key[1])
      elsif value[0].downcase == 'b'
        Bishop.new(self, value[0], value[1], key[0], key[1])
      elsif value[0].downcase == 'r'
        Rook.new(self, value[0], value[1], key[0], key[1])
      elsif value[0].downcase == 'p'
        Pawn.new(self, value[0], value[1], key[0], key[1])
      end
    end

  end


  def move(start, end_pos)
    #need to check legal move
    piece = self.grid[start[0]][start[1]]

    if piece.next_moves.include?(end_pos)
      self.grid[end_pos[0]][end_pos[1]] = piece
      self.grid[start[0]][start[1]] = nil

      piece.row = end_pos[0]
      piece.col = end_pos[1]
    else
      puts "Invalid move!"
    end
  end

  def in_check?(color)
    #debugger
    #loop through grid,if a piece is opposite color and its next_moves include the king with color, return false. else true
    (0..7).each do |r|
      (0..7).each do |c|
        p = @grid[r][c]
        if p && p.color != color
          p.next_moves.each do |target|
            row, col = target[0], target[1]
            if (@grid[row][col] && @grid[row][col].color == color) && @grid[row][col].name.upcase == 'K'
              return true
            end
          end
        end
      end
    end
    false
  end

  def dup
    hash = {}
    self.grid.each do |r|
      r.each do |item|
        if item
          hash[[item.row, item.col]] = [item.name, item.color]
        end
      end
    end
    Board.new(hash)
  end

  def print_board
    @grid.each do |row|
      grid_row = ""
      row.each do |piece|
        if piece
          grid_row += "#{piece.name}  "
        else
          grid_row  += "_  "
        end
      end
      p grid_row
    end
  end

end

if __FILE__ == $PROGRAM_NAME
  b = Board.new
  b.print_board

  puts
  b.move([6, 5], [5, 5])
  b.print_board

  puts
  b.move([1, 4], [2, 4])
  b.print_board

  puts
  b.move([6, 0 ], [5, 0])
  b.print_board

  puts
  q= b.grid[0][3]
  puts "queen moves: #{q.moves}"
  puts "queen next_moves: #{q.next_moves}"
  puts "queen valid_moves: #{q.valid_moves}"
  b.move([0, 3], [4, 7])
  b.print_board
  
  new_board = b.dup
  

  if b.in_check?('white')
    puts "White lose!!"
  end
end