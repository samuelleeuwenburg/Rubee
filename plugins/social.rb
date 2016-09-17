require "cinch"
require "json"
require "cleverbot"

class Social
  include Cinch::Plugin

  def initialize(*)
    super

    @bot         = Cleverbot::Client.new

    file         = File.read(File.dirname(__FILE__)+"/../settings.json")
    @rubee_data  = JSON.parse(file)
    @nick        = @rubee_data["nick"]

    file         = File.read(File.dirname(__FILE__)+"/social.json")
    @social_data = JSON.parse(file)
    @random      = @social_data['random']
    @odds        = @social_data['odds']
  end

  match(/^([^.!?+].*)$/i, method: :handle_match, use_prefix: false)
  def handle_match(m, message)
    if message.downcase.include? @nick
      reply = @bot.write message.downcase.gsub! @nick, ''
      m.reply "@#{m.user.nick}: #{reply}"

      return true
    end

    if @random and rand < @odds
      reply = @bot.write message.downcase.gsub! @nick, ''
      m.reply reply
    end
  end
end

