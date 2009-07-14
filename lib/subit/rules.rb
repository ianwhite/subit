module Subit
  class Rules < Array
    delegate :rule_class, :rule?, :to => 'Subit'
    
    # parses input using all rules in rules
    def parse(content, options = {})
      inject(content) {|parsed, rule| rule.parse(parsed, options)}
    end
    
    # parses input using all rules in rules, also modifies the
    # input according to any 'original' rules defined.
    def parse!(content, options = {})
      inject(options[:parsed] || content) do |parsed, rule|
        rule.for_original.parse!(content, options) if rule.for_original
        rule.parse(parsed, options)
      end
    end
    
    # add a rule to the set of rules, add either a rule object, or a rule name with args
    def add_rule(*args, &block)
      if rule?(args.first)
        self << args.first
      elsif klass = rule_class(args.shift)
        self << klass.new(*args, &block)
      else
        raise ArgumentError, "Unknown rule: #{args.first}"
      end
    end
  end
end