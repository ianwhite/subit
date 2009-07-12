module Subit
  # a NamedRules object contains stes of rules that can be stored and parsed by a series of
  # keys
  #
  # Example
  #
  #  You have rules for :html, :metric, and mixtures of both
  #
  #  Define these like this:
  #
  #   rules = Subit.define do 
  #     rule "init", "ins't it" # rule that is applied all the time
  #
  #     define :html do         # rules that are applied when asked for :html
  #       rule '&', '&amp;'
  #
  #       define :metric do     # rules that are applied only when asked for BOTH :metric AND :html
  #         ...
  #       end
  #     end
  #
  #     define :metric          # rules that are applied when asked for :metric
  #       ...
  #     end
  #   end
  class NamedRules
    def initialize(&block)
      define(&block)
    end
    
    def define(*keys, &block)
      
    end
  end
end