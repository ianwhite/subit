module Subit
  # a configurator object transforms dsl syntax into a series of #add calls on NamedRules and Rules objects
  class Configurator
    attr_reader :named_rules, :current_names
    
    def initialize(named_rules = Subit::NamedRules.new)
      @named_rules = named_rules
      @current_names = []
    end
    
    def define(*new_names, &block)
      new_names += current_names
      named_rules[new_names] || named_rules.add(new_names)
      with_names(new_names, &block)
      named_rules
    end
  
    def add(*args, &block)
      options = args.extract_options!
      if args.first.is_a?(Rule)
        args.first.exec ||= named_rules
      else
        options[:exec] ||= named_rules
      end
      current_rules.add(*args + [options], &block)
    end
    
    def rule(*args, &block)
      add(:rule, *args, &block)
    end
    
    def respond_to?(method, include_private = false)
      super || can_add_rule?(method)
    end
    
    def current_rules
      named_rules[current_names]
    end

    def with_names(new_names, &block)
      old_names = @current_names
      @current_names = new_names
      instance_eval(&block)
    ensure
      @current_names = old_names
    end
    
    def can_add_rule?(method)
      current_rules && current_rules.can_add_rule?(method)
    end
    
  protected
    def method_missing(method, *args, &block)
      return add(method, *args, &block) if can_add_rule?(method)
      super
    end
  end
end