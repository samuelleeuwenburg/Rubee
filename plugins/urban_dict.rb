require 'cinch'
require 'open-uri'
require 'nokogiri'
require 'cgi'
require "sequel"

class Dictionary
  include Cinch::Plugin

  def initialize(*)
    super

    @DB = Sequel.sqlite(File.dirname(__FILE__)+"/../rubee.db")
  end

  match(/^shut up(.+)/i, method: :shutUp, use_prefix: false)
  def shutUp(message)
    if message.downcase.include? @nick.downcase
      addBlacklistString(getLastMessage)
    end
  end

  def isBlacklistString?(string)
    blacklists = @DB[:urban_blacklist]
    blacklists.where(:string => string).one?
  end

  def addBlacklistString(string)
    blacklists = @DB[:urban_blacklist]
    blacklists.insert(:string => string)
  end

  def getLastMessage
    last = @DB[:urban_lastmessage]
    last.first
  end

  def setLastMessage(message)
    last = @DB[:urban_lastmessage]
    last.update(:last => last, :message => message)
  end

  match(/^(.+)\?\?\s*$/i, method: :urban_dict, use_prefix: false)
  match(/^\.u (.+)/i, method: :urban_dict, use_prefix: false)
  def urban_dict(m, query)

    if isBlacklistString?(query)
      exit
    end

    url        = "http://www.urbandictionary.com/define.php?term=#{CGI.escape(query)}"
    definition = Nokogiri::HTML(open(url)).at("div.meaning").text.gsub(/\s+/, ' ')
    limit = 220

    if definition.include? "There aren't any definitions"
      exit
    end

    if definition.length < limit
      m.reply query + ': ' + definition
    else
      m.reply query + ': ' + definition[0..limit] + '...'
    end
    setLastMessage(query)
  end
end
