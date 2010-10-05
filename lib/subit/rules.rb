module Subit
  class Rules < Array
    delegate :rule_class, :rule?, :to => 'Subit'
    
    # parses input using all rules in rules
    def parse(content, options = {})
      inject(content) {|parsed, rule| rule.parse(parsed, options)}
    end
    
    # parses input using all rules in rules, also modifies the
    # input according to any 'original' rules defined.
    def parse_with_parse_original!(content, options = {})
      inject(options[:parsed] || content.dup) do |parsed, rule|
        rule.for_original.parse!(content, options) if rule.for_original
        rule.parse(parsed, options)
      end
    end
    
    # add a rule to the set of rules, add either a rule object, or a rule name with args
    def add(*args, &block)
      if rule?(args.first)
        self << args.first
      elsif klass = rule_class(args.shift)
        self << klass.new(*args, &block)
      else
        raise ArgumentError, "Unknown rule: #{args.first}"
      end
    end
    
    def can_add_rule?(rule)
      rule?(rule) || rule_class(rule)
    end
    
    def +(other)
      self.dup.concat(other)
    end
    
    def dup
      super.map! {|rule| rule.dup }
    end
    
    # return a duplicate of this set of rules, with exec transferred from key to value
    def transfer_exec(from, to)
      map do |rule|
        rule.dup.tap {|r| r.exec = to if r.exec == from}
      end
    end
  end
end