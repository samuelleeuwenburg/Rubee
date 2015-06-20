require "cinch"

class Gassed
	include Cinch::Plugin

	def initialize(*)
		super

		@range = nil
		@answer = nil
		@guesses_left = nil
	end 

	match(/^guess the gassed +(\d+)?$/i, method: :start_gassed, use_prefix: false)
	def start_gassed(m, input_range=nil)
		if not input_range
			@range = rand(200)
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
		if @guesses_left > 1
			@guesses_left -= 1
			if guess == @answer
				m.reply("You guessed the gassed!, #{@answer}")
				reset_game(m)
			elsif guess < @answer
				m.reply("Higher, #{@guesses_left} guesses left")
			else
				m.reply("Lower, #{@guesses_left} guesses left")
			end

		else
			m.reply("Sorry, the number was #{@answer}")
			reset_game(m)
		end
	end

	match(/^end gassed$/i, method: :reset_game, use_prefix: false)
	def reset_game(m)
		if not @answer
			return false
		end

		@answer = nil
		m.reply("Game over")
	end
end