require 'cinch'
require 'open-uri'
require 'nokogiri'
require 'cgi'

class Google
  include Cinch::Plugin

  match(/^\.g (.+)/i, method: :search, use_prefix: false)
  def search(m, query)

    url = "http://www.google.com/search?q=#{CGI.escape(query)}"
    res = Nokogiri.parse(open(url).read).at("h3.r")
    title = res.text
    link = res.at('a')[:href]
    desc = res.at("./following::div").children.first.text

    bigdesc = Nokogiri.parse(open(url).read).at(".st").text

    m.reply "#{title} - #{desc}"
    m.reply bigdesc
    m.reply link[7..-1]
  end
end

