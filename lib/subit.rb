require 'logger'
require 'active_support'

module Subit
  extend self

  # return a new Subit::NamedRules object, pass a block to define rules and names
  def define(*args, &block)
    NamedRules.new(*args, &block)
  end
  
  def logger
    @logger ||= (Rails.logger rescue nil) || Logger.new(STDERR)
  end

  def logger=(logger)
    @logger = logger
  end
  
  def raise_parse_errors?
    @raise_parse_errors ? true : false
  end
  
  def raise_parse_errors=(value)
    @raise_parse_errors = value
  end
  
  def rule_classes
    @rule_classes ||= {}
  end
  
  def rule_class(symbol)
    rule_classes[symbol.to_s]
  end
  
  def register_rule(klass, name = klass.name.demodulize.underscore)
    rule_classes[name] = klass
  end
  
  def rule?(rule)
    rule_classes.values.detect {|klass| rule.is_a?(klass)}
  end
end

require 'subit/rule'
require 'subit/rules'
require 'subit/named_rules'
require 'subit/version'
require 'subit/configurator'