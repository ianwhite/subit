module Subit
  class Rule
    Subit.register_rule(self)
    
    attr_reader :search, :replacement
    attr_accessor :exec
    
    delegate :logger, :raise_parse_errors?, :to => 'Subit'
    
    def initialize(search, *args, &block)
      options = args.extract_options!
      @search = search
      @replacement = args.first || options[:replace] || block
      @exec = options[:exec]
    end
      
    def parse(content, options = {})
      content.gsub(@search) { perform_replace($~, options) }
    end
      
    def parse!(content, options = {})
      content.gsub!(@search) { perform_replace($~, options) }
    end
  
    def inspect
      "#<Subit::Rule #{@search.inspect} => #{@replacement.inspect}>"
    end
    
    def ==(other)
      [@search, @replacement] == [other.search, other.replacement]
    end
    
  protected
    def perform_replace(matchdata, options)
      case @replacement
      when String then replace_with_string(matchdata, options)
      when Proc   then replace_with_proc(matchdata, options)
      else             replace(matchdata, options)
      end
    rescue Exception => e
      raise e if raise_parse_errors?
      logger.error("[Subit] #{self.inspect} with: #{matchdata.inspect} got exception: #{e.inspect}")
      matchdata[0]
    end
    
    def replace(matchdata, options)
      # implement me in subclasses, default behaviour is to replace with nothing
    end
    
    def replace_with_string(matchdata, options)
      result = @replacement.dup
      matchdata.to_a.each_with_index {|match, i| result.gsub!("\\#{i}", match)}
      result
    end
    
    def replace_with_proc(matchdata, options)
      args = matchdata.to_a[1..-1]
      args += [options] if (args.size < @replacement.arity || @replacement.arity < 0)
      if exec = (options[:exec] || self.exec)
        exec.instance_exec(*args, &@replacement)
      else
        @replacement.call(*args)
      end
    end
  end
end