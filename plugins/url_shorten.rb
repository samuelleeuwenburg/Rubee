require 'open-uri'
require 'cinch'
class TinyURL
	include Cinch::Plugin


	match(/^.tu (.+)/, method: :shorten_url, use_prefix: false)
	def shorten_url(m, url)
		
		url = open("http://tinyurl.com/api-create.php?url=#{URI.escape(url)}").read
		
		m.reply url 
	end


	# listen_to :channel

	# def shorten(url)
	# 	url = open("http://tinyurl.com/api-create.php?url=#{URI.escape(url)}").read
	# 	url == "Error" ? nil : url

	# rescue OpenURI::HTTPError
	# 	nil
	# end

	# def listen(m)
	# 	urls = URI.extract(m.message, "http")
	# 	short_urls = urls.map { |url| shorten(url) }.compact

	# 	unless short_urls.empty?
	# 		m.reply short_urls.join(", ")
	# 	end
	# end

end
