require 'cinch'
require 'open-uri'
require 'nokogiri'
require 'cgi'

class Youtube 
	include Cinch::Plugin

	match(/^(http\:\/\/|https\:\/\/)?(www\.)?(youtube\.com|youtu\.?be)\/(.+)$/i, method: :search_title, use_prefix: false)
	def search_title(m, prefix, www, domain, query)

		url = "https://www.youtube.com/" + query
		res = Nokogiri.parse(open(url).read).at("#watch-header")
		title = res.at("h1").text.gsub! /\s{2,}|\n/, ""
		
		upvotes = res.at("#watch-like .yt-uix-button-content").text
		downvotes = res.at("#watch-dislike .yt-uix-button-content").text
		
		m.reply "#{title} - up: #{upvotes} down: #{downvotes}"
	end

	match(/^\.yt (.+)/i, method: :search, use_prefix: false)
	def search(m, query)
		
		url = "https://www.youtube.com/results?search_query=" + URI::encode(query)
		res = Nokogiri.parse(open(url).read).at("#content .item-section")

		q = res.at(".yt-lockup-title a")['href']
		url = "https://www.youtube.com/" + q

		res = Nokogiri.parse(open(url).read).at("#watch-header")
		title = res.at("h1").text.gsub! /\s{2,}|\n/, ""
		
		upvotes = res.at("#watch-like .yt-uix-button-content").text
		downvotes = res.at("#watch-dislike .yt-uix-button-content").text
		
		m.reply "#{title} - up: #{upvotes} down: #{downvotes}"
		m.reply url
	end

end
