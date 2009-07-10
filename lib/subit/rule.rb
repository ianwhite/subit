module Subit
  class Rule
    delegate :logger, :raise_parse_errors?, :to => 'Subit'
    
    def initialize(search, *args, &block)
      options = args.extract_options!
      @search = search
      @replacement = args.first || options[:replace] || block
      @bang_replacement = options[:replace!]
    end
      
    def parse(content, options = {})
      content.gsub(@search) { perform_replace(@replacement, $~, options) }
    end
      
    def parse!(content, options = {})
      if @bang_replacement
        returning parse(content, options) do
          content.gsub!(@search) { perform_replace(@bang_replacement, $~, options) }
        end
      else
        content.gsub!(@search) { perform_replace(@replacement, $~, options) }
      end
    end
  
    def inspect
      "#<Subit::Rule #{@search.inspect} replace:#{@replacement.inspect}#{" replace!:#{@bang_replacement.inspect}" if @bang_replacement}>"
    end
    
  protected
    def perform_replace(replacement, matchdata, options)
      case replacement
      when String then replace_with_string(replacement, matchdata, options)
      when Proc   then replace_with_proc(replacement, matchdata, options)
      else             replace(replacement, matchdata, options)
      end
    rescue Exception => e
      raise e if raise_parse_errors?
      logger.warn("[Subit] #{self.inspect} with: #{matchdata.inspect} got exception: #{e.inspect}")
      matchdata[0]
    end
    
    def replace(replacement, matchdata, options)
      # implement me in subclasses
    end
    
    def replace_with_string(replacement, matchdata, options)
      result = replacement.dup
      matchdata.to_a.each_with_index {|match, i| result.gsub!("$#{i}", match)}
      result
    end
    
    def replace_with_proc(replacement, matchdata, options)
      args = matchdata.to_a
      args += [options] if (args.size < replacement.arity || replacement.arity < 0)
      if options[:exec]
        options[:exec].instance_exec(*args, &replacement)
      else
        replacement.call(*args)
      end
    end
  end
end