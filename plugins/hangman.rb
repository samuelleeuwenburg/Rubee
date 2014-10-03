require 'cinch'

class Hangman
	include Cinch::Plugin
	
	def initialize(*)
		super
		
		@url = "http://www.tulpweb.nl/willekeurigwoord/"

		@word = nil
		@render = nil
		@tries = 10
		@guessed = []
	end

	def get_random_word()
		@word = Nokogiri::HTML(open(@url)).at(".mainbar .article h2").text
	end

	def render_guesses()
		alphabet = [
			"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", 
			"n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"
		]

		render = @word.clone

		for letter in @guessed
			if alphabet.include? letter
				alphabet.delete(letter)
			end
		end

		for letter in alphabet
			render.gsub! letter, "_"	
		end

		return render
	end

	def reset_game()
		@word = nil
		@tries = 10
		@guessed = []
	end

	match(/^hangman start$/i, method: :start_hangman, use_prefix: false)
	def start_hangman(m) 
		if not @word
			get_random_word()
			m.reply "A new game of hangman has started!"
		else 
			m.reply "A game is still ongoing"
		end
	end

	match(/^hangman end$/i, method: :end_hangman, use_prefix: false)
	def end_hangman(m) 
		if @word
			m.reply "The word was #{@word}"
			reset_game()
		else 
			m.reply "No game is currently in progress"
		end
	end

	match(/^guess ([a-zA-Z]{2,})$/i, method: :guess_entire_word, use_prefix: false)
	def guess_entire_word(m, word)
		if word == @word
			m.reply "Correct: #{@word}!"
			reset_game()
		else 
			@tries -= 1
			m.reply "Sorry, you have #{@tries} tries left"
		end
	end

	match(/^\guess ([a-zA-Z])$/i, method: :add_guess, use_prefix: false)
	def add_guess(m, guess)

		if @guessed.include? guess or not @word
			return false		
		end
		
		@guessed.push(guess)
		r = render_guesses()

		if r == @render
			@tries -= 1
		end

		@render = r.clone
				
		if @render.include? '_'
			m.reply "#{@render} - You have #{@tries} tries left"
			return false
		end

		m.reply "Correct: #{@render}!"
		reset_game()

	end

end
