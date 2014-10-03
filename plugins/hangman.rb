require 'cinch'
require "sequel"

class Hangman
	include Cinch::Plugin
	
	def initialize(*)
		super
		
		@url = "http://www.tulpweb.nl/willekeurigwoord/"

		@word = nil
		@tries = 10
		@geussed = []
	end

	def get_random_word()
		@word = Nokogiri::HTML(open(@url)).at(".mainbar .article h2").text
	end

	def render_geusses()
		alphabet = [
			"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", 
			"n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"
		]

		render = @word.clone

		for letter in @geussed
			if alphabet.include? letter
				alphabet.delete(letter)
			end
		end

		for letter in alphabet
			render.gsub! letter, "."	
		end

		return render
	end

	def reset_game()
		@word = nil
		@tries = 10
		@geussed = []
	end

	match(/^\.h start$/i, method: :start_hangman, use_prefix: false)
	def start_hangman(m) 
		if not @word
			get_random_word()
			m.reply "A new game of hangman has started!"
		else 
			m.reply "A game is still ongoing"
		end
	end

	match(/^\.h end$/i, method: :end_hangman, use_prefix: false)
	def end_hangman(m) 
		if @word
			m.reply "The word was #{@word}"
			reset_game()
		else 
			m.reply "No game is currently in progress"
		end
	end

	match(/^\.h ([a-zA-Z])$/i, method: :add_geuss, use_prefix: false)
	def add_geuss(m, geuss)
		if @geussed.include? geuss or not @word
			m.reply build_geussed()
			return false		
		end
		
		@geussed.push(geuss)
		r = render_geusses()

		if r.include? '.'
			@tries -= 1
			if @tries == 0
				m.reply "You lost the word was #{@word}"
				reset_game()
				return false
			else 
				m.reply "#{r} - You have #{@tries} tries left"
				return false
			end
		end
		addKarma m m.user.nick
		m.reply "Correct: #{r}!"
		reset_game()

	end

	def addKarma(m, nick)
		nicks = @DB[:karma]

		if m.user.to_s.capitalize == nick.capitalize 
			return false
		end

		unless nickExists(nick)
			addNick(nick)
		end
		
		n = nicks.where(:nick => nick.capitalize).first
		k = n[:karma] + 1
		nicks.where(:nick => nick.capitalize).update(:karma => k)

		m.reply renderKarma(nick)
	end


end
