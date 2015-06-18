require "cinch"
require 'open-uri'
require 'net/http'
require 'nokogiri'
require "sequel"


class Hangman
  include Cinch::Plugin

  def initialize(*)
    super

    @url = "http://www.miniwebtool.com/random-quote-generator/"
    @results = "3"
    @quotes = []
    @answer = nil
    @DB = Sequel.sqlite(File.dirname(__FILE__)+"/../rubee.db")

  end

  def reset_game()
    @quotes = []
    @answer = nil
  end

  match(/^quote start[o]?$/i, method: :start_quote, use_prefix: false)
  def start_quote(m)
    unless @answer
      uri = URI(@url)
      html = Net::HTTP.post_form(uri, "num" => @results)

      Nokogiri.parse(html.body).css(".p_1").each do |node|
        quote = node.css(".p_2") .text
        author = node.css(".p_3 a") .text

        @quotes.push({ author: author, quote: quote })
      end

      # set quote and answer 
      m.reply "#{@quotes.first()[:quote]}"
      @answer = @quotes.first()[:author]

      # shuffle the array
      @quotes.shuffle

      reply = "was a quote by: "
      @quotes.each_with_index do |quote, index|
        reply.concat "#{index}) #{quote[:author]}  "
      end
      reply.concat "?"

      m.reply reply
    else
      m.reply "A game is still ongoing"
    end
  end

  match(/^quote end$/i, method: :end_quote, use_prefix: false)
  def end_quote(m)
    if @answer
      m.reply "The answer was #{@answer}"
      reset_game()
    else
      m.reply "No game is currently in progress"
    end
  end

  match(/^answer ([0-9])$/i, method: :answer_quote, use_prefix: false)
  def answer_quote(m, input) 

    unless @quotes[input.to_i - 1].nil?
      answer = "#{@quotes[input.to_i - 1][:author]}" 

      if answer == @answer 
        addKarma m
        m.reply "Correct!"
        reset_game()
      else
        m.reply "Incorrect!"
      end
    end

  end

  def addKarma(m)
    nicks = @DB[:karma]
    nick = m.user.nick

    unless nickExists(nick)
      addNick(nick)
    end

    n = nicks.where(:nick => nick.capitalize).first
    k = n[:karma] + 1

    nicks.where(:nick => nick.capitalize).update(:karma => k)

    m.reply renderKarma(nick)
  end

  def renderKarma(nick)
    nicks = @DB[:karma]
    n     = nicks.where(:nick => nick.capitalize).first

    return "Karma for " + n[:nick] + " = " + n[:karma].to_s
  end

  def addNick(nick)
    nicks = @DB[:karma]
    nicks.insert(:nick => nick.capitalize, :karma => 0)
  end

  def nickExists(nick)
    nicks = @DB[:karma]
    n     = nicks.where(:nick => nick.capitalize).first

    if n
      return true
    else
      return false
    end
  end
end
