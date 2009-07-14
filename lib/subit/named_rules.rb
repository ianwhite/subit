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
      options = names.extract_options!
      options[:names] = names = sanitize_names(names)
      
      rules_for(names).inject(content) do |parsed, rules|
        rules.parse(parsed, options)
      end
    end
    
    # like parse, but also modifying the original content using rule.for_original
    def parse!(content, *names)
      options = names.extract_options!
      options[:names] = sanitize_names(names)
      
      rules_for(names).inject(content) do |parsed, rules|
        rules.parse!(content, options.merge(:parsed => parsed))
      end
    end
    
    def add_rules(names, rules = Rules.new)
      store(sanitize_names(names), rules)
    end
    
    def [](*names)
      super(sanitize_names(names))
    end
  
  protected
    # return rules that are subsets of the given names
    def rules_for(names)
      keys.sort.select {|k| (k - names).empty? }.map {|k| fetch(k) }
    end
  
    def sanitize_names(names)
      names.map(&:to_s).uniq.sort
    end
  end
end