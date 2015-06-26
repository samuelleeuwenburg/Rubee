require "cinch"
require "sequel"

class Karma
  include Cinch::Plugin

  listen_to :add_karma

  def initialize(*)
    super

    @DB = Sequel.sqlite(File.dirname(__FILE__)+"/../rubee.db")
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

  match(/^karma (\w+)\s?$/i, method: :getKarma, use_prefix: false)
  def getKarma(m, nick)
    unless nickExists(nick)
      addNick(nick)
    end

    m.reply renderKarma(nick)
  end

  match(/^(\w+)\+\+$/i, method: :addKarma, use_prefix: false)
  def addKarma(m, nick)
    nicks = @DB[:karma]

    if m.user.to_s.capitalize == nick.capitalize
      return false
    end

    unless nickExists(nick)
      addNick(nick)
    end

    n = nicks.where(:nick => nick.capitalize).first
    k = n[:karma] + 1

    nicks.where(:nick => nick.capitalize).update(:karma => k)

    m.reply renderKarma(nick)
  end

  match(/^highscore/i, method: :highscore, use_prefix: false)
  def highscore(m)
    results = @DB['select * from karma ORDER BY karma DESC LIMIT 0, 3']
    prefix  = "Karma top 3: "
    losers  = []

    for result in results
      losers.push("#{result[:nick]} (#{result[:karma]})")
    end

    reply = losers.join(", ")

    m.reply "#{prefix} #{reply}"
  end
end

