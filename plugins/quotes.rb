require "cinch"
require 'open-uri'
require 'net/http'
require 'nokogiri'
require "sequel"


class Quote 
  include Cinch::Plugin

  def initialize(*)
    super

    @url = "http://www.miniwebtool.com/random-quote-generator/"
    @results = "5"
    @quotes = []
    @answer = nil
    @DB = Sequel.sqlite(File.dirname(__FILE__)+"/../rubee.db")

    @cooldown = 600
    @timer = @cooldown
    @onCooldown = false

  end

  def reset_game()
    @quotes = []
    @answer = nil

    startCooldown()
  end

  def startCooldown
    if not @onCooldown
      @onCooldown = true

      while @timer != 0
        sleep(1)
        @timer -= 1
      end

      @timer = @cooldown
      @onCooldown = false
    end
  end

  match(/^quote start[o]?$/i, method: :start_quote, use_prefix: false)
  def start_quote(m)
    if @onCooldown
      timeLeft = (Time.mktime(0)+@timer).strftime("%M:%S")
      m.reply "Game is on cooldown, try again in #{timeLeft} minutes"
      return false
    end

    unless @answer
      uri = URI(@url)
      html = Net::HTTP.post_form(uri, "num" => @results)

      Nokogiri.parse(html.body).css(".p_1").each do |node|
        quote = node.css(".p_2") .text
        author = node.css(".p_3 a") .text

        @quotes.push({ author: author, quote: quote })
      end

      #get random entry
      sample = @quotes.sample

      # set quote and answer 
      m.reply "#{sample[:quote]}"
      @answer = sample[:author]

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

  match(/^guess ([0-9])$/i, method: :answer_quote, use_prefix: false)
  def answer_quote(m, input) 

    unless @quotes[input.to_i].nil?
      answer = "#{@quotes[input.to_i][:author]}" 

      if answer == @answer 
        addKarma m
        m.reply "Correct!"
        reset_game()
      else
        m.reply "Incorrect, the answer was #{@answer}"
        reset_game()
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
