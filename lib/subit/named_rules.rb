module Subit
  # a NamedRules object contains stes of rules that can be stored and parsed by a series of keys
  class NamedRules < Hash
    # usage:
    #   named_rules.parse(str)                  # => will parse str using root rules
    #   named_rules.parse(str, :html)           # => will parse str using :html rules, and root rules
    #   named_rules.parse(str, :html, :metric)  # => will parse str using root rules, :html rules, :metric rules and [:html, :metric] rules
    #
    # to parse using only the [:html, :metric] RuleSet do this:
    #   named_rules[:html, :metric].parse(str)
    #
    def parse(content, *names)
      perform_parse(:parse, content, *names)
    end
    
    # like parse, but also modifying the original content using rule.for_original
    def parse!(content, *names)
      perform_parse(:parse!, content, *names)
    end
    
    def add_rules(names, rules = Rules.new)
      store(sanitize_names(names), rules)
    end
    
    def [](*names)
      names = names.first if names.first.is_a?(Array)
      super(sanitize_names(names))
    end
  
  protected
    def perform_parse(method, content, *names)
      options = names.extract_options!
      options[:names] = sanitize_names(names)
      
      rules_for(names).inject(content) do |parsed, rules|
        rules.send(method, parsed, options.merge(:parsed => parsed))
      end
    end

    # return rules that are subsets of the given names
    def rules_for(names)
      names = sanitize_names(names)
      keys.sort.select do |key|
        (key - names).empty? # select keys which are subsets of names
      end.map do |key|
        fetch(key) # and retreive the rules for those keys
      end
    end
  
    def sanitize_names(names)
      names.map(&:to_s).uniq.sort
    end
  end
end