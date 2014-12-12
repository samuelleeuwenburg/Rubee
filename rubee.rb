require "cinch"
require "cinch/plugins/identify"
require "json"

# Require all of plugins
Dir[File.dirname(__FILE__)+"/plugins/*.rb"].each {|file| require file}

bot = Cinch::Bot.new do
	configure do |c|

		file = File.read(File.dirname(__FILE__)+"/settings.json")
		rubee_data = JSON.parse(file)

		c.server = rubee_data["server"] 
		c.ssl.use = rubee_data["ssl"] 

        if rubee_data["serverpwd"]
            c.password = rubee_data["serverpwd"]
        end

		c.channels = rubee_data["channels"]
		c.nick = rubee_data["nick"]
		c.user = rubee_data["nick"] 

		c.plugins.plugins = [
			Cinch::Plugins::Identify,
			Karma,
			TinyURL,
			Google,
			Hangman,
			Youtube,
			Dictionary,
			Social
		]
		
		c.plugins.options[Cinch::Plugins::Identify] = {
			:username => rubee_data["nick"],
			:password => rubee_data["password"],
			:type => :nickserv,
		}

	end
end

bot.start
