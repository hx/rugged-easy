require 'rugged/easy/version'
require 'rugged/easy/repository'

module Rugged
  module Easy
    def self.on(*args, &block)
      Repository.new *args, &block
    end
  end

  def Easy(*args, &block)
    Easy::Repository.new *args, &block
  end

  module_function :Easy
end
