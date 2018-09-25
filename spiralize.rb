#https://www.codewars.com/kata/make-a-spiral/ruby
class Cell
  attr_reader :row, :col
  attr_accessor :n, :s, :e, :w, :mark

  def initialize(row,col)
    @row, @col = row, col
    @mark = 0
  end

  def mark
    @mark
  end
end

class Grid
  attr_reader :rows, :cols
  def initialize(rows,cols)
    @rows, @cols = rows, cols
    @grid = make_grid
    cell_config
  end

  def make_grid
    Array.new(rows) do |row|
      Array.new(cols) do |col|
        Cell.new(row,col)
      end
    end
  end

  def cell_config
    each_cell do |cell|
      row, col = cell.row, cell.col

      cell.n = self[row - 1, col]
      cell.s = self[row + 1, col]
      cell.e = self[row, col + 1]
      cell.w = self[row, col - 1]
      cell.mark = 0
    end
  end

  def each_row
    @grid.each do |row|
      yield row
    end
  end

  def each_cell
    each_row do |row|
      row.each do |cell|
        yield cell if cell
      end
    end
  end

  def [](row,col)
    return nil unless row.between?(0, @rows - 1)
    return nil unless col.between?(0, @cols - 1)
    @grid[row][col]
  end

  def begin_spiral
    self[0,0].mark = 1
    go_east(0,1) if self[0,0].e != nil
  end

  def go_east(r,c)
    return if !self[r + 1, c].nil? && self[r + 1, c].mark == 1
    self[r,c].mark = 1
    if c == @cols - 1
      go_south(r + 1, c)
    elsif self[r,c+2] != nil && self[r,c+2].mark == 1
      if self[r + 2, c - 1].mark != 1
        go_south(r + 1, c)
      else
        return
      end
    else
      go_east(r, c + 1)
    end
  end

  def go_south(r,c)
    self[r,c].mark = 1
    if r == @rows - 1
      go_west(r, c - 1)
    elsif self[r + 2, c] != nil && self[r + 2, c].mark == 1
      if self[r - 1, c - 1].mark == 1
        return
      else
        go_west(r, c - 1)
      end
    else
      go_south(r + 1, c)
    end
  end

  def go_west(r, c)
    return if @rows == 2
    self[r,c].mark = 1
    if c == 0
      go_north(r - 1, c)
    elsif self[r, c - 2] != nil && self[r, c - 2].mark == 1
      if self[r - 2, c].mark != 1
        go_north(r - 1, c)
      else
        return
      end
    else
      go_west(r, c - 1)
    end
  end

  def go_north(r,c)
    return if @rows == 3
    self[r,c].mark = 1
    if self[r - 2,c] != nil  && self[r-2, c].mark == 1
      if self[r, c + 2].mark != 1
        go_east(r, c + 1)
      else
        return
      end
    else
      go_north(r - 1, c)
    end
  end

  def marks
    marks = @grid.map do |row|
      row.map {|e| e.mark}
    end
    marks
  end

  def to_s
    each_row do |row|
      p row.map {|e| e.mark}
    end
  end
end

def spiralize(size)
  return [] if size == 0
  g = Grid.new(size,size)
  g.begin_spiral
  g.marks
end
