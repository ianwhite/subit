require 'set'
require 'logger'
require 'subit/rule'
require 'subit/rules'
require 'subit/version'

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
end