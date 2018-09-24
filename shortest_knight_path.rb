KNIGHT_MOVES = [[-2,-1],[-2,1],[-1,2],[1,2],[2,1],[2,-1],[1,-2],[-1,-2]]
class Square
  attr_accessor :neighbors, :position
  def initialize(row, column)
    @neighbors = Array.new
    @position = [row,column]
    @square = make_position(row,column)
  end

  def make_position(row,column)
    cols = ("a".."h").to_a.reverse!
    return cols[column] + (row + 1).to_s
  end

  def add_pos(pos)
    [@position[0] + pos[0], @position[1] + pos[1]]
  end

  def add_neighbor(pos)
    @neighbors << make_position(pos[0],pos[1])
  end
end

class Board

  attr_accessor :grid
  def initialize
    @grid = make_grid
    neighborize
  end

  def make_grid
    Array.new(8) do |row|
      Array.new(8) do |col|
        Square.new(row,col)
      end
    end
  end

  def [](pos)
    return nil unless pos[0].between?(0,7)
    return nil unless pos[1].between?(0,7)
    @grid[pos[0]][pos[1]]
  end

  def each_rank
    @grid.each do |rank|
      yield rank
    end
  end

  def each_square
    each_rank do |rank|
      rank.each do |sq|
        yield sq
      end
    end
  end

  def neighborize
    each_square do |sq|
      KNIGHT_MOVES.each do |pos|
        new_square = sq.add_pos(pos)
        if self[new_square] != nil
          sq.add_neighbor(new_square)
        end
      end
    end
  end

  def square_to_coords(sq)
    cols = ("a".."h").to_a.reverse!
    sq = sq.split("")
    [sq[1].to_i - 1, cols.index(sq[0])]
  end


  def shortest_path(start,finish)
    sq = start
    start = square_to_coords(start)
    root = Node.new(nil, self[start].neighbors, sq)
    build_tree(root,finish)
  end

  def build_tree(root,target)
    queue = [root]
    until queue[0].value == target
      queue[0].children.each do |child|
        neighbors = self[square_to_coords(child)].neighbors
        queue << Node.new(queue[0], neighbors, child)
      end
      queue.shift
    end
    if queue[0].value == target
      return trace_path(queue[0])
    end
  end

  def trace_path(node)
    sqs = []
    current_node = node
    until current_node.parent.nil?
      sqs << current_node.value
      current_node = current_node.parent
    end
    return sqs.length
  end
end

class Node
  attr_reader :parent, :children, :value
  def initialize(parent,children,value)
    @parent = parent
    @children = children
    @value = value
  end
end

def knight(start, finish)
  Board.new.shortest_path(start,finish)
end
