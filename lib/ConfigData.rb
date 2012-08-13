
# Represents data read from a configuration file.
# 
# Instance Variables:
#   @array is an array where each element is a line from the config file.
#   @hash is a hash containing all key/value pairs found in the config file
#     where the general format is [key]:[value]. Keys are symbolized, so they
#     must begin with a letter and consist only of letters, numbers and
#     underscores. Values are passed to eval(), so they can/must be valid
#     Ruby code.
#   @has_data is boolean flag indicating whether data was successfully read.
#   @error is the error message if an exception was raised.
# 
# @author wyattisimo
# 
class ConfigData
  
  CONFIGS_DIR = 'configs/'
  
  attr_reader :array, :hash, :has_data, :error
  
  
  # Loads config data from the specified file.
  # 
  # @param fname [Symbol or String] the file name
  # @param o [Hash] additional options
  #   :do_parse [Bool] parse the data for key/value pairs (default: true)
  #   :strip_comments [Bool] strip comments from the data (default: true)
  #   :ignore_empty [Bool] ignore empty lines (default: true)
  
  def initialize(fname, o={})
    
    # ensure the keys in the options hash are symbols
    o.keys.each{|k| o[k.to_sym] = o.delete(k)}
    
    do_parse = o.has_key?(:do_parse) && o[:do_parse]===false ?
      false : true
    strip_comments = o.has_key?(:strip_comments) && o[:strip_comments]===false ?
      false : true
    ignore_empty = o.has_key?(:ignore_empty) && o[:ignore_empty]===false ?
      false : true
    
    @array = []
    @hash = {}
    
    begin
      file = File.open("#{CONFIGS_DIR}#{fname.to_s}", "r")
      file.each_line do |line|
        
        # remove comments (attempts to match comments preceeded with a #)
        if strip_comments
          line = line.match(/^(("(\\"|[^"])*"|'(\\'|[^'])*'|[^#])*)/)[0]
        end
        
        # ignore empty lines
        if ignore_empty
          next if line.strip.empty?
        end
        
        # push this line to the data array
        @array.push line unless line.empty?
      end
      
      # parse out key/value pairs
      if do_parse
        i=0; while i < @array.size
          line = @array[i]
          
          _, key, value = line.match(/^\s*([a-z][\w]*)\s*:\s*(.+)$/i).
            to_a.map(&:strip)
          
          # ignore lines that don't contain a key/value pair
          next unless key.instance_of?(String) && value.instance_of?(String)
          
          # multi-line values are recognized by lines ending with a backslash \
          value = value.chomp('\\') + @array[i+=1].strip while
            value.split('').last == '\\'
          
          # add this key/value to the data hash
          if value.match /[^\d\.]/
            # use eval on everything except literal decimal numbers
            @hash[key.to_sym] = eval(value)
          else
            @hash[key.to_sym] = value
          end
          
          i+=1
        end
      end
      
      raise StandardError, "Config file is empty." if @array.count == 0
      raise StandardError, "No key/value pairs found in config file. " +
        "Set the :do_parse option to false to skip parsing." if
        do_parse && @hash.count == 0
      
      @has_data = true
      @error = nil
      
    rescue Exception => err_msg
      @has_data = false
      @error = err_msg
    end
  end
  
  
  def has_data?
    @has_data
  end
  
end