require 'cinch'
require 'open-uri'
require 'nokogiri'
require 'cgi'
require "sequel"

class Dictionary
  include Cinch::Plugin

  def initialize(*)
    super

    @db = Sequel.sqlite(File.dirname(__FILE__)+"/../rubee.db")
  end

  match(/^shut up(.+)/i, method: :shut_up, use_prefix: false)
  def shut_up(message)
    if message.downcase.include? @nick.downcase
      add_blacklist_string(get_last_message)
    end
  end

  def is_blacklist_string?(string)
    blacklists = @db[:urban_blacklist]
    blacklists.where(:string => string).one?
  end

  def add_blacklist_string(string)
    blacklists = @db[:urban_blacklist]
    blacklists.insert(:string => string)
  end

  def get_last_message
    last = @db[:urban_lastmessage]
    last.first
  end

  def set_last_message(message)
    last = @db[:urban_lastmessage]
    last.update(:last => last, :message => message)
  end

  match(/^(.+)\?\?\s*$/i, method: :urban_dict, use_prefix: false)
  match(/^\.u (.+)/i, method: :urban_dict, use_prefix: false)
  def urban_dict(m, query)

    if is_blacklist_string?(query)
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
    set_last_message(query)
  end
end
