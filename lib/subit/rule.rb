module Subit
  class Rule
    attr_reader :search, :replacement, :bang_replacement
    
    delegate :logger, :to => 'Subit.logger'
    
    def initialize(search, *args, &block)
      options = args.extract_options!
      @search = search
      @replacement = args.first || options[:replace] || block
      @bang_replacement = options[:replace!]
    end
      
    def parse(content, options = {})
      content.gsub(search) { perform_replace(replacement, $~, options) }
    end
      
    def parse!(content, options = {})
      if bang_replacement
        returning parse(content, options) do
          content.gsub!(search) { perform_replace(bang_replacement, $~, options) }
        end
      else
        content.gsub!(search) { perform_replace(replacement, $~, options) }
      end
    end
  
  protected
    def perform_replace(replacement, matchdata, options)
      case replacement
      when String
        result = replacement.dup
        matchdata.to_a.each_with_index {|match, i| result.gsub!("$#{i}", match)}
        result
      when Proc
        args = matchdata.to_a
        args += [options] if (args.size < replacement.arity || replacement.arity < 0)
        (options[:eval] || self).instance_exec(*args, &replacement)
      else
        replace(replacement, matchdata, options)
      end
    end
    
    def replace(replacement, matchdata, options)
      # implement me in subclasses
    end
  end
end