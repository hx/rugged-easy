require 'rugged'
require 'pathname'

module Rugged
  module Easy
    class Repository
      attr_reader :path

      def initialize(dir, **opts, &block)
        @opts = opts
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
        Rugged::Repository.init_at path, args.include?(:bare)
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

      def commit(*args)
        symbols, strings = split_args(*args)
        amend            = symbols.include? :amend
        index            = repo.index
        data             = {
            author:     author,
            committer:  author,
            message:    strings.first || '',
            update_ref: 'HEAD'
        }
        index.reload
        if amend
          data[:tree] = index.write_tree
          repo.head.target.amend data
        else
          data[:parents] = []
          unless repo.head_unborn?
            last_commit = repo.head.target
            # index.read_tree last_commit.tree
            data[:parents] << last_commit
          end
          data[:tree] = index.write_tree
          Rugged::Commit.create(repo, data)
        end
        self
      end

      # private

      def author
        {
            name:  get_option(:user_name),
            email: get_option(:user_email),
            time:  Time.now
        }
      end

      def get_option(key)
        @opts[key] || Easy.get_option(key)
      end

      def split_args(*args, **opts)
        symbols, strings = args.partition { |arg| arg.is_a? Symbol }
        symbols.concat opts.keys
        strings.concat opts.values
        [symbols, strings]
      end

      def repo
        Rugged::Repository.new(path.to_s)
      end

    end
  end
end
