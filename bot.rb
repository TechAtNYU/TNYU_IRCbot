require 'cinch'

# Automatically include all available plugins
$plugins = []
Dir['plugins/*'].each do |plugin|
  begin
    require_relative plugin
    $plugins.push Module.const_get(plugin.match(/plugins\/([\w]+).rb/)[1])
  rescue LoadError; end
end

# Bot configuration
bot = Cinch::Bot.new do
  configure do |c|
    c.nick = 'tnyubot'
    c.server = 'irc.freenode.org'
    c.channels = ['#tech@nyu']
    c.plugins.plugins = $plugins
    c.plugins.prefix = nil
  end
end

# Go, daddy, go!
bot.start