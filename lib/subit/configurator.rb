module Subit
  # a configurator object transforms dsl syntax into a series of #add calls on NamedRules and Rules objects
  class Configurator
    attr_reader :named_rules, :names
    
    delegate :rule_class, :to => 'Subit'
    
    def initialize(named_rules = Subit::NamedRules.new, &block)
      @named_rules = named_rules
      @names = []
    end
    
    def define(*new_names, &block)
      new_names += names
      named_rules[new_names] || named_rules.add(new_names)
      with_names(new_names, &block)
    end
  
  protected
    def with_names(new_names, &block)
      old_names = self.names
      @names = new_names
      instance_eval(&block)
    ensure
      @names = old_names
    end
  end
end