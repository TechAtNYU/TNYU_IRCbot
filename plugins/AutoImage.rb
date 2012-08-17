require 'google/api_client'

# This runs a Google image search and posts a relevant image link when a user
# in the channel provides a file name matching the regex below.
# 
# General format:  [query].[file_type]
# 
# @author wyattisimo
# 
class AutoImage
  include Cinch::Plugin
  
  match /([\w'-_!]+)\.(gif|jpg|jpeg|png)/, :react_on => :channel
  
  def execute(m, query, file_type)
    
    query.gsub! /[-_]+/, ' '
    
    file_type = 'jpg' if file_type == 'jpeg'
    
    # search
    client = Google::APIClient.new(
      :key => ENV['GOOGLE_API_KEY'],
      :authorization => nil)
    search = client.discovered_api('customsearch')
    response = client.execute(
      :api_method => search.cse.list,
      :parameters => {
        'q' => query,
        'key' => ENV['GOOGLE_API_KEY'],
        'cx' => ENV['GOOGLE_CSE_ID'],
        'searchType' => 'image',
        'fileType' => file_type,
        'filter' => 1 # enable duplicate content filter
      }).response
puts "#{response}"
    
    # Post an image link (randomly choose from top ten search results)
    if response.success?
      items = JSON.parse(response.body)['items']
puts "SUCCESS #{items[rand 0..items.size]['link'].gsub(/\?.*$/, '')}"
      m.reply items[rand 0..items.size]['link'].gsub(/\?.*$/, '') if items
    end
  end
  
end