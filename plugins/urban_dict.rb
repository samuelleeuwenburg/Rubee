require 'cinch'
require 'open-uri'
require 'nokogiri'
require 'cgi'


class Dictionary
	include Cinch::Plugin	

	match(/^.u (.+)/, method: :urban_dict, use_prefix: false)
	def urban_dict(m, query)
		
		url = "http://www.urbandictionary.com/define.php?term=#{CGI.escape(query)}"
		definition =  Nokogiri::HTML(open(url)).at("div.meaning").text.gsub(/\s+/, ' ')
		
		m.reply query + ': ' + definition
	end
end

