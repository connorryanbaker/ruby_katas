class QueenProblem
  attr_accessor :board, :queen_positions, :size
  def initialize(n)
    @size = n
    @board = Array.new(n) { Array.new(n) }
    @queen_positions = Hash.new()
  end

  def solve
    @board[0][0] = "Q"
    @queen_positions[0] = [0,0]
    place_next_queen(1)
  end

  def place_next_queen(row)
    return if row > @size
    @board[row].each_index do |col|
      if !under_attack(row,col)
        @queen_positions[row] = [row, col]
        @board[row][col] = "Q"
        to_s
        return success if solved?
        return place_next_queen(row + 1)
      end
    end
    backtrack(row - 1) if @queen_positions[row].nil?
  end

  def solved?
    return false if @queen_positions.keys.length < @size
    @queen_positions.values.each_with_index do |val,i|
      return false if under_attack(val[0], val[1])
    end
    true
  end

  def under_attack(row, col)
    @queen_positions.keys.each_with_index do |key, i|
      unless @queen_positions[key] == [row,col]
        return true if @queen_positions[key][0] == row || @queen_positions[key][1] == col
        return true if row + col == @queen_positions[key][0] + @queen_positions[key][1]
        return true if row - col == @queen_positions[key][0] - @queen_positions[key][1]
      end
    end
    return false
  end

  def backtrack(row)
    old_row, old_col = @queen_positions[row][0], @queen_positions[row][1]
    if old_col + 1 == @size
      @queen_positions.delete(old_row)
      @board[row][old_col] = nil
      backtrack(row - 1)
    else
      @queen_positions[row] = [old_row, old_col + 1]
      @board[row][old_col] = nil
      @board[row][old_col + 1] = "Q"
      return backtrack(row) if under_attack(old_row, old_col + 1)
      place_next_queen(row + 1)
    end
  end

  def to_s
    @board.each do |row|
      p row.map {|e| e.nil? ? " " : "Q"}
      p
    end
    p ' '
  end

  def success
    self.to_s
    p "WE DID IT"
    return @queen_positions
  end
end
