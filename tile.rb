require './board'

class Tile
  POS_DIFF = [[0,-1],[1,-1],[1,0],[1,1],[0,1],[-1,1], [-1,0],[-1,-1]]
  attr_accessor :bombed, :flagged, :revealed, :pos
  
  def initialize(win,pos, board)
    @pos = pos # array of two  elements
    @x,@y = pos[0],pos[1]
    @bombed = false
    @flagged = false
    @revealed = false
    @board = board
    @win = win
  end
  
  # Returns true if reveal occurs, false otherwise 
  def reveal
    @revealed = true 
    if @bombed
      return false
    elsif neighbor_bomb_count == 0
      neighbors.each do |neighbor| 
        unless neighbor.revealed
          neighbor.reveal
        end  
      end    
      return true
    end      
  end
  
  def neighbors
    neighbor_pos = []
    
    POS_DIFF.each do |square_pos|
      x, y = square_pos
      my_x, my_y = @pos
      new_pos = [x + my_x, y + my_y]
      neighbor_pos << new_pos if @board.is_valid?(new_pos)
    end 
    
    neighbor_pos.map { |pos| @board.get_tile(pos) } 
  end 
  
  def neighbor_bomb_count 
    neighbors.select { |neigbor| neigbor.bombed }.count
  end 
      
  def to_s
    if @flagged
      return "F"
    elsif @revealed
      count = neighbor_bomb_count
      return count == 0 ? "_" : "#{count}" 
    else
      return "*"  
    end
  end
  
  
  
  def draw_flag_square
    col1 = 0xFFFF0000
    col2 = 0xFF000000
    @win.draw_quad(@x, @y, col2,
                  @x, @y+1, col1,
                  @x+1,@y,col2,
                  @x+1,@y+1,col1)
    
  end
  
  def draw_revealed_square
    col1 = 0xFF00FF00
    col2 = 0XFF00FF55
    @win.draw_quad(@x, @y, col2,
                  @x, @y+1, col1,
                  @x+1,@y,col2,
                  @x+1,@y+1,col1)
  end
  
  def draw_number_square
    #neighbor_bomb_count
    bombs = neighbor_bomb_count
    col1 = 0xFFFFFF00 / neighbor_bomb_count
    col2 = 0XFFFFAA00 / neighbor_bomb_count
    @win.draw_quad(@x, @y, col1,
                  @x, @y+1, col2,
                  @x+1,@y,col1,
                  @x+1,@y+1,col2)
    #f.draw(neighbor_bomb_count.to_s, @x.fdiv(@board.rat), @y.fdiv(@board.rat), 0.7)
  end
  
  def draw_square
    col1 = 0xFF808080
    col2 = 0x00808080
    @win.draw_quad(@x, @y, col1,
                  @x, @y+1, col2,
                  @x+1,@y,col1,
                  @x+1,@y+1,col2)
  end
  
  def draw
    if @flagged
      draw_flag_square
    elsif @revealed
      count = neighbor_bomb_count
      if count == 0
        draw_revealed_square
      else
        draw_number_square
      end
    else
      draw_square
    end
  end
end
  
  
    