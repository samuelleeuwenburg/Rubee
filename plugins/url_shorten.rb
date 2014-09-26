require 'open-uri'
require 'cinch'
class TinyURL
	include Cinch::Plugin


	match(/^\.tu (.+)/, method: :shorten_url, use_prefix: false)
	def shorten_url(m, url)
		
		url = open("http://tinyurl.com/api-create.php?url=#{URI.escape(url)}").read
		
		m.reply url 
	end

end
