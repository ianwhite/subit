module Subit
  class Rules
    attr_reader :rules 
    
    delegate :rule_class, :rule?, :to => 'Subit'
    
    def initialize(&block)
      @rules = []
      instance_eval(&block) if block
    end
    
    # parses input using all rules in rules
    def parse(original_content, options = {})
      rules.inject(original_content) {|parsed, rule| rule.parse(parsed, options)}
    end
    
    # parses input using all rules in rules, also modifies the
    # input according to any 'original' rules defined.
    def parse!(original_content, options = {})
      rules.inject(original_content) do |parsed, rule|
        rule.for_original.parse!(original_content, options) if rule.for_original
        rule.parse(parsed, options)
      end
    end
    
    def add(*args, &block)
      if rule?(args.first)
        rules << args.first
      else
        rules << rule_class(args.shift).new(*args, &block)
      end
    end
    
    def respond_to?(method)
      super(method) || rule_class(method)
    end
    
  protected
    def method_missing(method, *args, &block)
      if rule_class(method)
        add(method, *args, &block)
      else
        super
      end
    end
  end
end