require "cinch"
require "cinch/plugins/identify"
require "json"

# Require all of plugins
Dir[File.dirname(__FILE__)+"/plugins/*.rb"].each {|file| require file}

bot = Cinch::Bot.new do
	configure do |c|

		file = File.read("rubee.json")
		rubee_data = JSON.parse(file)

		c.server = rubee_data["server"] 
		c.channels = rubee_data["channels"]
		c.nick = rubee_data["nick"]
		c.user = rubee_data["nick"] 

		c.plugins.plugins = [
			Cinch::Plugins::Identify,
			Social,
			TinyURL,
			Google,
			Dictionary
		]
		
		c.plugins.options[Cinch::Plugins::Identify] = {
			:username => rubee_data["nick"],
			:password => rubee_data["password"],
			:type => :nickserv,
		}

	end
end


bot.start
