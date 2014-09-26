require "cinch"
require "sequel"

class Karma 
	include Cinch::Plugin
	DB = Sequel.connect("sqlite://rubee.db")

	def renderKarma(nick)
		nicks = DB[:karma]
		n = nicks.where(:nick => nick).first
		return "Karma for " + n[:nick] + " = " + n[:karma].to_s
	end

	def addNick(nick)
		nicks = DB[:karma]
		nicks.insert(:nick => nick, :karma => 0)
	end

	def nickExists(nick)
		nicks = DB[:karma]
		n = nicks.where(:nick => nick).first
		if n
			return true
		else 
			return false
		end	
	end

	match(/^\.k (\w+)$/, method: :getKarma, use_prefix: false)
	def getKarma(m, nick)
		unless nickExists(nick)
			addNick(nick)
		end

		m.reply renderKarma(nick)
	end

	match(/^\+(\w+)$/i, method: :addKarma, use_prefix: false)
	def addKarma(m, nick)
		nicks = DB[:karma]

		if m.user.to_s == nick
			return false
		end

		unless nickExists(nick)
			addNick(nick)
		end
		
		n = nicks.where(:nick => nick).first
		k = n[:karma] + 1
		nicks.where(:nick => nick).update(:karma => k)

		m.reply renderKarma(nick)
	end

end
