require 'google/api_client'

# This runs a Google image search and posts a relevant image link when a user
# in the channel provides a file name on its own line matching the regex below.
# 
# General format:  [query].[file_type]
# 
class AutoImage
  include Cinch::Plugin
  
  match /^([\w-]+)\.(gif|jpg|png)$/, :react_on => :channel
  
  def execute(m, query, file_type)
    
    query.gsub! /-/, ' '
    
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
        'fileType' => file_type
      }).response
    
    # Post an image link (randomly choose from top ten search results)
    if response.success?
      items = JSON.parse(response.body)['items']
      m.reply items[rand 0..9]['link'] if items
    end
  end
  
end