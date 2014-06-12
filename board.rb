require './tile'


class Board
  
  attr_reader :dimension, :rat
  
  def initialize(window, dimension, bombs)
    @window = window
    @dimension = dimension
    @num_bombs = bombs
    @flags_remaining = bombs
    @bomb_count_text = Font.new(window, "Courier", 2)
    @grid = Array.new(@dimension) {Array.new(@dimension)}
    @grid.each_with_index do |row,i|
      row.each_index do |j|
        pos = [i, j]
        @grid[i][j] = Tile.new(window, pos, self)
      end 
    end 
    
    @rat = @window.width.fdiv(@dimension)
    
    create_board
    
  end 
  
  def draw
    @img.draw(0,0,0.5)
  end
  
  def paint
    @img = @window.record(@dimension, @dimension) do
       @grid.each do |row|
           row.each do |tile|
             tile.draw
             end
         end
     end
  end
  
  def update
    #mouse over to get number
  
    paint
  end
  
  
  
  def display
    print "    #{(0...@dimension).to_a}\n"
    transposed = @grid.transpose
    transposed.each_with_index do |col,index|
      puts "#{index} | #{col}"
    end
        
  end
  
  def won?
    correct_flags == @num_bombs
  end
  
  def show_bomb_number(x,y)
    tile = get_tile([(x.fdiv(@rat)).to_i,(y.fdiv(@rat)).to_i])
    if tile.revealed
      @bomb_count_text.draw(tile.neighbor_bomb_count.to_s,0,0,0.6)
      #@window.height-(@window.height/10),0.6)
    end
  end
  
  #when a particular tile is clicked
  def reveal_clicked(x,y)
    tile = get_tile([(x.fdiv(@rat)).to_i,(y.fdiv(@rat)).to_i])
    value = reveal_tile(tile.pos)
    paint
    return value
  end
  
  def flag_clicked(x,y)
    tile = get_tile([(x.fdiv(@rat)).to_i,(y.fdiv(@rat)).to_i])
    add_flag(tile.pos) || remove_flag(tile.pos)
    paint
  end
  
  def create_board
    @grid.flatten.sample(@num_bombs).each{ |tile| tile.bombed = true }
  end
  
  def is_valid?(pos)
    x,y = pos
    (0...@dimension).include?(x) && (0...@dimension).include?(y)
  end
  
  def get_tile(pos)
    x, y = pos
    @grid[x][y]
  end 
  
  def set_bomb(pos)
    x,y = pos
    @grid[x][y].bombed = true
  end
  
  #returns true on successful remove flag
  def remove_flag(pos)
    tile = get_tile(pos)
    unless tile.revealed && !tile.flagged
      tile.flagged = false
      true 
    else 
      false 
    end 
  end 


  #returns true on succesful add flag
  def add_flag(pos)
    tile = get_tile(pos)
    unless tile.revealed && tile.flagged
      tile.flagged = true
      true
    else 
      false
    end   
  end 
  
  def reveal_tile(pos)
    states = {
      :game_over => false,
      :valid => true,
      :correct_flags => false
    }
    
    tile = get_tile(pos)
    if correct_flags?
      states[:correct_flags] = true
    end
    
    unless tile.flagged || tile.revealed
      if get_tile(pos).bombed
        states[:game_over] = true
      end 
      get_tile(pos).reveal
    else
      states[:valid] = false      
    end
    states
  end
   
  #flags on bomb counter
  def correct_flags?
    flags = 0
    @grid.each do |row|
      row.each do |tile|
        flags+=1 if tile.flagged && tile.bombed
      end
    end
    flags == @num_bombs
  end
  
  def end_display
    print "    #{(0...@dimension).to_a}\n"
    transposed = @grid.transpose
    transposed.each_with_index do |row,index|
      new_row = row.map do |tile|
        tile.bombed ? "B" : tile.to_s
      end 
      puts "#{index} | #{new_row}"
    end
    
  end 
end

