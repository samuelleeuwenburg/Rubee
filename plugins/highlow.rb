require "cinch"

class Highlow
  include Cinch::Plugin

  def initialize(*)
    super

    @range = nil
    @answer = nil
    @guesses_left = nil
  end 

  match(/^highlow start ?(\d+)?$/i, method: :start_gassed, use_prefix: false)
  def start_gassed(m, input_range=nil)
    if not input_range
      @range = rand(100) + 100
    else 
      @range = Integer(input_range)
    end 
    
    @guesses_left = 6
    @answer = rand(@range)
    m.reply("I'm thinking of a number between 0 and #{@range}")
  end

  match(/^guess (\d+)$/i, method: :play, use_prefix: false)
  def play(m, guess) 
    if not @answer  
      return false
    end

    guess = Integer(guess)
    if guess != @answer
      @guesses_left -= 1

      if @guesses_left == 0
        m.reply("Sorry, you lose. The answer was #{@answer}")
        reset_game(m)
        return false
      end

      if guess > @answer
        m.reply("Lower, #{@guesses_left} guesses left")
      else
        m.reply("Higher, #{@guesses_left} guesses left")
      end

    else
      if @guesses_left == 6
        m.reply("Sniped!")
      end
      m.reply("Correct, it was #{@answer}!")
      reset_game(m)
    end
  end

  match(/^end highlow$/i, method: :reset_game, use_prefix: false)
  def reset_game(m)
    if not @answer
      return false
    end

    @answer = nil
    m.reply("Game over")
  end

  #todo: implement karma update
end