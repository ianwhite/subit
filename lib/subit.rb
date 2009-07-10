require 'subit/rules'
require 'subit/version'

module Subit
  extend self
  
  def rules(*args, &block)
    Rules.new(*args, &block)
  end
end