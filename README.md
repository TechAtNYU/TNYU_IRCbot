TNYU_IRCbot
===========

IRC bot for #tech@nyu on freenode


Adding Features (Plugins)
-------------------------

This bot uses [cinch](https://github.com/cinchrb/cinch), which makes it mad-super-easy to add features.
Just write a plugin and put it in the `plugins/` directory.
Check out some [plugin examples](https://github.com/cinchrb/cinch/tree/master/examples/plugins)
and take a look at the [plugin documentation](http://rubydoc.info/gems/cinch/Cinch/Plugin) for more information.

**IMPORTANT:** Don't forget to add your plugin's dependencies to the Gemfile!

Configuration Files
-------------------

Configuration files are located in `configs/`.
If you want to use a configuration file with your plugin, please place it there
and give it the same name as your plugin so we know what's what.

`ConfigData` is a configuration data parser that you can use to easily read files located in `configs/`.
It will create an array where each element is a line from your config file, 
and attempt to create a hash of any key/value pairs in the form `[key]: [value]`.
It ignores empty lines and comments preceeded with `#`.
See [`lib/ConfigData.rb`](https://github.com/TechAtNYU/TNYU_IRCbot/blob/master/lib/ConfigData.rb) for more information.

For example, if you create `/configs/MyConfig` and its contents are:
```
# this is my config file

juju: "Magic Ju-ju"
awesome_level: 7

I am a lonely string at the end of a file...
```

then you can access your data as follows:
```ruby
mydata = ConfigData.new :MyConfig
mydata.hash[:juju]
  #=> "Magic Ju-ju"
mydata.array[2]
  #=> "I am a lonely string at the end of a file..."
```
