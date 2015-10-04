require 'rugged'

module Rugged
  module Easy
    class Repository

      attr_reader :path

      def initialize(path, &block)
        @path = path
        if block_given?
          case block.arity
            when 0
              instance_eval &block
            when 1
              block.call self
            when 2
              block.call self, repo
            else
              raise ArgumentError, 'Expected a block that takes 0-2 arguments'
          end
        end
      end

      private

      def repo
        @repo ||= Rugged::Repository.new(path)
      end

    end
  end
end
