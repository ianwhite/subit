require 'set'
require 'logger'
require 'active_support'
require 'subit/rule'
require 'subit/rule_for_original'
require 'subit/rules'
require 'subit/version'

Subit::Rule.send :include, Subit::RuleForOriginal

module Subit
  extend self

  def rules(*args, &block)
    Rules.new(*args, &block)
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
end