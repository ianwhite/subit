module Subit
  # mixin for Rule that allows specification of a rule for replacing text in the original string
  #
  # the extra rule is specified with the :original option.
  #
  # This can be either a rule itself, or a string or proc, in which case a rule will be made
  # with the same search expression and the replacement that is specified.
  module RuleForOriginal
    def self.included(rule)
      rule.class_eval do
        attr_reader :for_original
        alias_method_chain :initialize, :rule_for_original
      end
    end
    
    def initialize_with_rule_for_original(search, *args, &block)
      options = args.dup.extract_options!
      if original = options.delete(:original)
        @for_original = if original.is_a?(Subit::Rule)
          original
        else
          self.class.new(search, original)
        end
      end
      initialize_without_rule_for_original(search, *args, &block)
    end
  end
end