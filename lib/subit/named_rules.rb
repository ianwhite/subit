module Subit
  # a NamedRules object contains sets of rules that can be stored and parsed by a series of keys
  class NamedRules < ActiveSupport::OrderedHash
    attr_accessor :name
    
    # optionally define some rules on custruction
    def initialize(*names, &block)
      super(&nil)
      options = names.extract_options!
      @name = options[:name]
      define(*names, &block) if block_given?
    end
    
    def to_s
      "<#{@name || 'Subit::NamedRules'} #{keys.inspect}>"
    end
    
    # define this object using the passed block
    def define(*names, &block)
      Configurator.new(self).define(*names, &block)
    end
    
    # usage:
    #   named_rules.parse(str)                  # => will parse str using root rules
    #   named_rules.parse(str, :html)           # => will parse str using :html rules, and root rules
    #   named_rules.parse(str, :html, :metric)  # => will parse str using root rules, :html rules, :metric rules and [:html, :metric] rules
    #
    # to parse using only the [:html, :metric] RuleSet do this:
    #   named_rules[:html, :metric].parse(str)
    #
    def parse(content, *names)
      options = extract_options_and_sanitize_names!(names)
      rules_for(names).inject(content) {|out, rules| rules.parse(out, options)}
    end
    
    # like parse, but also modifying the original content using rule.for_original when defined
    def parse_with_parse_original!(content, *names)
      options = extract_options_and_sanitize_names!(names)
      rules_for(names).inject(content) do |parsed, rules|
        rules.parse_with_parse_original!(content, options.merge(:parsed => parsed))
      end
    end
    
    # add a Rules object for a names array
    def add(names, rules = Rules.new)
      self[sanitize_names!(names)] = rules
    end
    
    # access the Rules object - can call with splat, i.e. r[:html, :metric]
    def [](*names)
      names = names.first if names.first.is_a?(Array)
      super(sanitize_names!(names))
    end
  
    # return rules that are subsets of the given names
    def rules_for(names)
      sanitize_names!(names)
      keys.select do |k|
        (k - names).empty? # select keys which are subsets of names
      end.map do |k|
        self[k]
      end
    end
    
    def +(other)
      addition = NamedRules.new
      self.each do |key, rules|
        addition[key] = rules.transfer_exec(self, addition)
      end
      other.each do |key, rules|
        addition[key] ||= Rules.new
        addition[key] += rules.transfer_exec(other, addition)
      end
      mixins = (self.singleton_class.included_modules | other.singleton_class.included_modules) - addition.singleton_class.included_modules
      addition.singleton_class.send :include, *mixins if mixins.any?
      addition
    end
    
  protected
    def sanitize_names!(names)
      names.map!(&:to_s).uniq!
      names.sort!
    end
    
    def extract_options_and_sanitize_names!(names)
      options = names.extract_options!
      sanitize_names!(names)
      options.merge(:names => names)
    end
  end
end