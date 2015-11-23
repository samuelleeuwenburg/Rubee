require 'cinch'
require 'open-uri'
require 'nokogiri'
require 'cgi'

class Dictionary
  include Cinch::Plugin

  match(/^(.+)\?\s*$/i, method: :urban_dict, use_prefix: false)
  match(/^\.u (.+)/i, method: :urban_dict, use_prefix: false)
  def urban_dict(m, query)
    url        = "http://www.urbandictionary.com/define.php?term=#{CGI.escape(query)}"
    definition = Nokogiri::HTML(open(url)).at("div.meaning").text.gsub(/\s+/, ' ')
    limit = 220

    unless definition.include? "There aren't any definitions"
      if definition.length < limit
        m.reply query + ': ' + definition
      else
        m.reply query + ': ' + definition[0..limit] + '...'
      end
    end
  end
end

