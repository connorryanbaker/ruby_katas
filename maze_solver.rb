#https://www.codewars.com/kata/escape-the-maze/train/ruby
require 'benchmark'
class Grid
  attr_reader :rows, :columns, :grid, :exit, :start
  def initialize(array,ex)
    @rows = array.length
    @columns = array[0].length
    @grid = make_grid(array)
    configure_cells
    @exit = self[ex[0],ex[1]]
  end

  def make_grid(array)
    grid = Array.new(@rows) { Array.new(@columns) }
    array.each_with_index do |row, ri|
      row = row.split("")
      row.each_with_index do |col, ci|
        if col == "#"
          grid[ri][ci] = Boundary.new(ri, ci)
        elsif col == " "
          grid[ri][ci] = Cell.new(ri, ci)
        elsif col != " " || col != "#"
          grid[ri][ci] = Cell.new(ri, ci, escape=false, start=true)
          @start = grid[ri][ci]
          grid[ri][ci].orient(col)
        end
      end
    end
    grid
  end

  def each_row
    @grid.each do |row|
      yield row
    end
  end

  def each_cell
    each_row do |row|
      row.each do |cell|
        if cell.is_a?(Cell)
          yield cell
        end
      end
    end
  end

  def [](row, column)
    return nil unless row.between?(0, @grid.length - 1)
    return nil unless column.between?(0, @grid[row].count - 1)
    @grid[row][column]
  end

  def configure_cells
    each_cell do |cell|
      row, col = cell.row, cell.column
      cell.n = [row - 1, col] if self[row - 1, col].is_a?(Cell)
      cell.s = [row + 1, col] if self [row + 1, col].is_a?(Cell)
      cell.e = [row, col + 1] if self[row, col + 1].is_a?(Cell)
      cell.w = [row, col - 1] if self[row, col - 1].is_a?(Cell)
    end
  end
  def distances
    distances = Distances.new(@start, self)
    frontier = [ @start ]
    while frontier.any?
      new_frontier = []
      frontier.each do |cell|
        cell.nsew.each do |neighbor|
          next if distances[self[neighbor[0],neighbor[1]]]
          distances[self[neighbor[0],neighbor[1]]] = distances[cell] + 1
          new_frontier << self[neighbor[0],neighbor[1]]
        end
      end
      frontier = new_frontier
    end
    distances
  end

  def find_path
    distances = self.distances
    path = distances.path_to(@exit,self)
    rough = path.cells.map {|e| [e.row, e.column]}
    start = rough.shift
    rough << start
    arr = rough.reverse << [@exit.row, @exit.column]
    direction_array(arr)
  end

  def direction_array(cells)
    directions = []
    cells.each_with_index do |e,i|
      facing = @start.direction
      break if i == cells.length - 1
      directions.concat(compare_position(cells[i], cells[i + 1], facing))
    end
    directions
  end

  def compare_position(one, two, facing)
    if [one[0] - two[0], one[1] - two[1]] == [1,0]
      go_north(facing)
    elsif [one[0] - two[0], one[1] - two[1]] == [0, -1]
      go_east(facing)
    elsif [one[0] - two[0], one[1] - two[1]] == [-1, 0]
      go_south(facing)
    else
      go_west(facing)
    end
  end

  def go_north(facing)
    if facing == "U"
      ["F"]
    elsif facing == "L"
      @start.direction = "U"
      ["R", "F"]
    elsif facing == "R"
      @start.direction = "U"
      ["L", "F"]
    else
      @start.direction = "U"
      ["B", "F"]
    end

  end

  def go_east(facing)
    if facing == "U"
      @start.direction = "R"
      ["R", "F"]
    elsif facing == "L"
      @start.direction = "R"
      ["B", "F"]
    elsif facing == "R"
      ["F"]
    else
      @start.direction = "R"
      ["L", "F"]
    end
  end

  def go_south(facing)
    if facing == "U"
      @start.direction = "D"
      ["B", "F"]
    elsif facing == "L"
      @start.direction = "D"
      ["L", "F"]
    elsif facing == "R"
      @start.direction = "D"
      ["R", "F"]
    else
      ["F"]
    end
  end

  def go_west(facing)
    if facing == "U"
      @start.direction = "L"
      ["L", "F"]
    elsif facing == "L"
      ["F"]
    elsif facing == "R"
      @start.direction = "L"
      ["B", "F"]
    else
      @start.direction = "L"
      ["R", "F"]
    end
  end
end

class Boundary
  attr_reader :row, :column
  def initialize(row, column)
    @row, @column = row, column
  end
end

class Cell
  attr_reader :row, :column
  attr_accessor :n, :s, :e, :w, :escape, :start, :direction

  def initialize(row, column, escape = false, start = false)
    @row, @column, @escape, @start = row, column, escape, start
  end

  def orient(symbol)
    directions = { "<" => "L",
      ">" => "R",
      "^" => "U",
      "v" => "D"}
    @direction = directions[symbol]
  end

  def nsew
    arr = [@n, @s, @e, @w].reject {|e| e.nil?}
  end
end

class Distances
  def initialize(root, grid)
    @root = root
    @cells = {}
    @cells[@root] = 0
    @grid = grid
  end

  def [](cell)
    @cells[cell]
  end

  def []=(cell, distance)
    @cells[cell] = distance
  end

  def cells
    @cells.keys
  end

  def path_to(goal,grid)
    current = goal
    breadcrumbs = Distances.new(@root, grid)
    until current == @root
      current.nsew.each do |neighbor|
        if @cells[@grid[neighbor[0], neighbor[1]]] < @cells[current]
          breadcrumbs[@grid[neighbor[0], neighbor[1]]] = @cells[neighbor]
          current = @grid[neighbor[0], neighbor[1]]
          break
        end
      end
    end
    breadcrumbs
  end
end

def escape(maze)
    ex = is_it_impossible(maze)
    if ex == true
      return []
    else
      p Grid.new(maze, ex).find_path
    end
end
def is_it_impossible(array)
  result = true
  array.each_with_index do |row, ri|
    row = row.split("")
    row.each_with_index do |col, ci|
      if ri == 0 || ri == array.length - 1 || ci == 0 || ci == row.length - 1
        result = [ri, ci] if col == " "
      end
    end
  end
  result
end
p  Benchmark.realtime {
    escape([
      '####### #',
      '#>#   # #',
      '#   #   #',
      '#########'
    ])
    escape([
  "#########################################",
  "#<    #       #     #         # #   #   #",
  "##### # ##### # ### # # ##### # # # ### #",
  "# #   #   #   #   #   # #     #   #   # #",
  "# # # ### # ########### # ####### # # # #",
  "#   #   # # #       #   # #   #   # #   #",
  "####### # # # ##### # ### # # # #########",
  "#   #     # #     # #   #   # # #       #",
  "# # ####### ### ### ##### ### # ####### #",
  "# #             #   #     #   #   #   # #",
  "# ############### ### ##### ##### # # # #",
  "#               #     #   #   #   # #   #",
  "##### ####### # ######### # # # ### #####",
  "#   # #   #   # #         # # # #       #",
  "# # # # # # ### # # ####### # # ### ### #",
  "# # #   # # #     #   #     # #     #   #",
  "# # ##### # # ####### # ##### ####### # #",
  "# #     # # # #   # # #     # #       # #",
  "# ##### ### # ### # # ##### # # ### ### #",
  "#     #     #     #   #     #   #   #   #",
  "#########################################"
])
escape([
"#########################################",
"#<    #       #     #         # #   #   #",
"##### # ##### # ### # # ##### # # # ### #",
"# #   #   #   #   #   # #     #   #   # #",
"# # # ### # ########### # ####### # # # #",
"#   #   # # #       #   # #   #   # #   #",
"####### # # # ##### # ### # # # #########",
"#   #     # #     # #   #   # # #       #",
"# # ####### ### ### ##### ### # ####### #",
"# #             #   #     #   #   #   # #",
"# ############### ### ##### ##### # # # #",
"#               #     #   #   #   # #   #",
"##### ####### # ######### # # # ### #####",
"#   # #   #   # #         # # # #       #",
"# # # # # # ### # # ####### # # ### ### #",
"# # #   # # #     #   #     # #     #   #",
"# # ##### # # ####### # ##### ####### # #",
"# #     # # # #   # # #     # #       # #",
"# ##### ### # ### # # ##### # # ### ### #",
"#     #     #     #   #     #   #   #    ",
"#########################################"
])
escape([
"#########################################",
"#<    #       #     #         # #   #   #",
"##### # ##### # ### # # ##### # # # ### #",
"# #   #   #   #   #   # #     #   #   # #",
"# # # ### # ########### # ####### # # # #",
"#   #   # # #       #   # #   #   # #   #",
"####### # # # ##### # ### # # # #########",
"#   #     # #     # #   #   # # #       #",
"# # ####### ### ### ##### ### # ####### #",
"# #             #   #     #   #   #   # #",
"# ############### ### ##### ##### # # # #",
"#               #     #   #   #   # #   #",
"##### ####### # ######### # # # ### #####",
"#   # #   #   # #         # # # #       #",
"# # # # # # ### # # ####### # # ### ### #",
"# # #   # # #     #   #     # #     #   #",
"# # ##### # # ####### # ##### ####### # #",
"# #     # # # #   # # #     # #       # #",
"# ##### ### # ### # # ##### # # ### ### #",
"#     #     #     #   #     #   #   #    ",
"#########################################"
])
escape([
"#########################################",
"#<    #       #     #         # #   #   #",
"##### # ##### # ### # # ##### # # # ### #",
"# #   #   #   #   #   # #     #   #   # #",
"# # # ### # ########### # ####### # # # #",
"#   #   # # #       #   # #   #   # #   #",
"####### # # # ##### # ### # # # #########",
"#   #     # #     # #   #   # # #       #",
"# # ####### ### ### ##### ### # ####### #",
"# #             #   #     #   #   #   # #",
"# ############### ### ##### ##### # # # #",
"#               #     #   #   #   # #   #",
"##### ####### # ######### # # # ### #####",
"#   # #   #   # #         # # # #       #",
"# # # # # # ### # # ####### # # ### ### #",
"# # #   # # #     #   #     # #     #   #",
"# # ##### # # ####### # ##### ####### # #",
"# #     # # # #   # # #     # #       # #",
"# ##### ### # ### # # ##### # # ### ### #",
"#     #     #     #   #     #   #   #    ",
"#########################################"
])
  escape([
  '##########',
  '#        #',
  '#  ##### #',
  '#  #   # #',
  '#  #^# # #',
  '#  ### # #',
  '#      # #',
  '######## #'
])
escape([
  '####### #',
  '#>#   # #',
  '#   #   #',
  '#########'
])
}
