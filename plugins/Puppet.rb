
# Use tnyubot as a puppet }:)
# 
# General format:  say|do [channel] [message]
# 
# @author wyattisimo
#
class Puppet
  include Cinch::Plugin
  
  match /^(say|do)\s+(.+)$/, :react_on => :private
  
  def execute(m, action, what)
    p = ConfigData.new :Puppet
    if p.hash[:puppet_masters].include? m.user.user
      if action == 'say'
        _, channel, message = what.match(/(#[^\s]+\s+)?(.+)/).
          to_a.map{|a| a.strip if a.class==String}
        m.bot.irc.send "PRIVMSG #{channel || m.user} :#{message}"
      elsif action == 'do'
        #TODO
      end
    end
  end
end