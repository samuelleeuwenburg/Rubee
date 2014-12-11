require "cinch"
require "sequel"

class Hangman
	include Cinch::Plugin

	def initialize(*)
		super
		
		@url = "http://www.tulpweb.nl/willekeurigwoord/"

		@word    = nil
		@render  = nil
		@tries   = 8
		@guessed = []

		@DB = Sequel.sqlite(File.dirname(__FILE__)+"/../rubee.db")
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
		@tries = 7
		@guessed = []
	end

	match(/^hangman start[o]?$/i, method: :start_hangman, use_prefix: false)
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
		if not @word
			return false
		end

		if word == @word
			m.reply "Correct: #{@word}!"
			addKarma m
			reset_game()
		else
			@tries -= 1
			m.reply "Sorry #{@tries} tries left"

			if @tries == 0
				m.reply "You lose, the word was #{@word}"
				reset_game()
			end
		end
	end

	match(/^guess ([a-zA-Z])$/i, method: :add_guess, use_prefix: false)
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

			if @tries == 0
				m.reply "Sorry you lose, the word was #{@word}"
				reset_game()
			end
			return false
		end

		addKarma m
		m.reply "Correct: #{@render}!"
		reset_game()

	end

	def addKarma(m)
		nicks = @DB[:karma]
		nick = m.user.nick

		unless nickExists(nick)
			addNick(nick)
		end

		n = nicks.where(:nick => nick.capitalize).first
		k = n[:karma] + 1
		nicks.where(:nick => nick.capitalize).update(:karma => k)

		m.reply renderKarma(nick)
	end

	def renderKarma(nick)
		nicks = @DB[:karma]
		n = nicks.where(:nick => nick.capitalize).first
		return "Karma for " + n[:nick] + " = " + n[:karma].to_s
	end

	def addNick(nick)
		nicks = @DB[:karma]
		nicks.insert(:nick => nick.capitalize, :karma => 0)
	end

	def nickExists(nick)
		nicks = @DB[:karma]
		n = nicks.where(:nick => nick.capitalize).first
		if n
			return true
		else
			return false
		end
	end
end

