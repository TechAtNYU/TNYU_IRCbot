require 'cinch'
require './lib/ConfigData'

# ENVIRONMENT determines the nick of the bot, the channels it joins, etc.
# ENV['BOT_ENVIRONMENT'] should be either "production" or "test".
# If unspecified, the default is :test. See configs/bot_config for more info.
begin
  ENVIRONMENT = ENV['BOT_ENVIRONMENT'].to_sym
  raise unless ENVIRONMENT == :production
rescue
  ENVIRONMENT = :test
end

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
  config = ConfigData.new :bot_config
  raise config.error unless config.has_data?
  config = config.hash[ENVIRONMENT]
  
  configure do |c|
    c.server = config[:server]
    c.channels = config[:channels]
    c.nick = config[:nick]
    if config.has_key? :username
      c.sasl.username = config[:username]
      c.sasl.password = ENV['IRC_PASSWORD']
    end
    c.plugins.plugins = $plugins
    c.plugins.prefix = nil
  end
  
  on :op do |m|
    if m.user == bot_name
      msgs = ConfigData.new :op_msgs, {do_parse: false}
      m.reply msgs.array[rand 0..(msgs.array.count-1)] if msgs.has_data?
    end
  end
end

# Go, daddy, go!
puts "\nActivating TNYU_IRCbot with ENVIRONMENT = #{ENVIRONMENT} . . .\n\n"
bot.start
