require 'gosu'
require './board'
require 'yaml'
include Gosu

class Minesweeper < Gosu::Window
  
  attr
  
  def initialize()
    puts "Leaderboard"
    display_winners
    
    puts "Would you like to start a new game? Y/N?"
    input = gets.chomp.downcase.to_sym
    if input == :y 
      puts "Choose a board size"
      @dimension = Integer(gets.chomp)
      puts "You chose #{@dimension} for your size"
      puts "Choose a difficulty, e m or h"
      @game_state = {:game_over => false,
                      :correct_flags => false}
      @diff = gets.chomp.to_sym
      @start_time = Time.new
      case @diff 
      when :e 
        bombs = (@dimension ** 2) / 10
      when :m
        bombs = (@dimension ** 2) / 7
      when :h
        bombs = (@dimension ** 2) / 5
      end 
      @flags_remaining = bombs
      
      @game_over = false
      @timer_set = false
      @score = 0
    else 
      puts "Enter a filename"
      file_name = gets.chomp
      @board, @flags_remaining = YAML.load_file(file_name)
      run 
    end 
    square_pixel_length = 15
    super(@dimension*square_pixel_length, @dimension*square_pixel_length, true)
    @board = Board.new(self, @dimension, bombs)
    self.caption = "Minesweeper"
    self.show
  end     
  
  
  def needs_cursor?
    true
  end
  
  
  def button_down(id)
     case id
     when KbEscape
        close
     when MsLeft
       @game_state = @board.reveal_clicked(mouse_x, mouse_y)
     when MsRight
       @board.flag_clicked(mouse_x, mouse_y)
     when KbR
        @map.reset
      when KbSpace
        @board.show_bomb_number(mouse_x,mouse_y)
     end
  end
  
  def update
    if @game_state[:game_over] 
      self.close
      puts "You lose!"
    elsif @game_state[:correct_flags]
      game_complete
      self.close
    end
    @board.update
  end
  
  def draw
    scale(@board.rat, @board.rat) {
      @board.draw
    }
  end   

  
  def display_winners
    leaderboard = YAML.load_file("leaderboard.save")
    array = leaderboard.sort_by { |name, score| score }
    array.each do |name, score|
      puts "#{name}: #{score}"
    end 
  end 
  
  def game_complete
    elapsed_time = (Time.new - @start_time).to_i
    puts "The game completed in #{elapsed_time.to_i} seconds "

    puts "Input your name!"
    name = gets.chomp
    diff_hash = { :e => 1, :m => 2, :h => 3 }
    diff_multiplier = diff_hash[@diff]
    puts "#{diff_multiplier} diff mul, #{@dimension} dim,"
    score = (diff_multiplier * @dimension * 13000) / elapsed_time
    
    score_hash = YAML.load_file("leaderboard.save")
    score_hash[name] = score 
    File.open("leaderboard.save", "w") do |f|
      f.puts score_hash.to_yaml
    end 
  end
  
  def lost?
    @game_over
  end 
  
  def one_turn
    @board.display
    puts "You have #{@flags_remaining} flags left."
    input = parse_input
    command, pos = input[:command], input[:pos]
    if command == :f
      toggle_flag(pos)
    elsif command == :r
      reveal_tile(pos)
    end    
  end
  
  def reveal_tile(pos)
    states = @board.reveal_tile(pos) 
    if states[:game_over]
      @game_over = true
    elsif !states[:valid]
      puts "Invalid move"
    end 
  end
  
  def parse_input
    begin
      puts "Input command (r or f) followed by the position xy. No spaces"
      puts "Or input 'save' to save progress"
      str = gets.chomp
      if str == "save"
        save 
        
      else 
        command = str[0].to_sym
        pos = [Integer(str[1]), Integer(str[2])]      
      end 
      
        raise BadInputError, "Invalid command" unless [:r, :f].include?(command)
        raise BadInputError, "Invalid Positions" unless @board.is_valid?(pos)
      
        rescue BadInputError => e
          puts e.message      
          retry 
        rescue ArgumentError => e
          puts e.message    
          retry
        
      end 
    
    { :command => command , :pos => pos }
  end

  
  
  def save
    game_yaml = [@board, @flags_remaining].to_yaml
    File.open("Minesweeper.save", "w") do |f|
      f.puts game_yaml
    end 
    puts "Your game has been saved"
  end
  
  def toggle_flag(pos)
    flag = @board.get_tile(pos).flagged
    if flag
      remove_flag(pos)
    elsif @flags_remaining > 0
      add_flag(pos)
    else 
      puts "You're out of flags"
    end 
  end 
  
  def add_flag(pos)
    if @board.add_flag(pos)
      @flags_remaining -= 1
    end 
  end 
  
  def remove_flag(pos)
    if @board.remove_flag(pos)
      @flags_remaining += 1
    end 
  end 
  
  def get_flagged(pos)
    @board.get_tile(pos).flagged
  end 

  
end

class BadInputError < StandardError
  def initialize(message)
    super(message)
  end
end 

if __FILE__ == $PROGRAM_NAME
  m = Minesweeper.new

end