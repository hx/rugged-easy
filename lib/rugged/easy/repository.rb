require 'rugged'
require 'pathname'

module Rugged
  module Easy
    class Repository
      attr_reader :path

      def initialize(dir, &block)
        @path = Pathname(dir)
        raise 'Supplied path is a file; expected a directory or nonexistent path.' if path.file?
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

      def init(*args)
        @repo = Rugged::Repository.init_at path, args.include?(:bare)
        self
      end

      def add(*globs)
        root = path.realpath
        index = repo.index
        globs.each do |glob|
          Dir[root + glob].each do |abs_path|
            abs_path = Pathname(abs_path)
            next if abs_path.directory?
            rel_path = abs_path.relative_path_from(root)
            index.add path: rel_path.to_s,
                      mode: abs_path.stat.mode,
                      oid:  Rugged::Blob.from_workdir(repo, rel_path.to_s)
          end
        end
        index.write
        self
      end

      private

      def repo
        @repo ||= Rugged::Repository.new(path.to_s)
      end

    end
  end
end
