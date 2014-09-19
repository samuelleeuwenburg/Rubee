require "cinch"
require "json"

class Social
	include Cinch::Plugin

	file = File.read("rubee.json")
	rubee_data = JSON.parse(file)

	nick = rubee_data["nick"]

	match(/^bye #{nick}$|^doei #{nick}$/i, method: :goodbye, use_prefix: false)
	def goodbye(m)
		m.reply "Goodbye, #{m.user.nick}"
	end

	match(/^hello #{nick}$|^hi #{nick}$|^hoi #{nick}$|^hallo #{nick}$/i, method: :hello, use_prefix: false)
	def hello(m)
		m.reply "Hello, #{m.user.nick}!"
	end

end
