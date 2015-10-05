require 'rugged/easy/version'
require 'rugged/easy/repository'

module Rugged
  module Easy
    def self.on(*args, &block)
      Repository.new *args, &block
    end

    def self.default_options
      @default_options ||= {
          user_name: name,
          user_email: 'rugged@easy'
      }.freeze
    end

    default_options.each_key do |key|
      define_method(key) { @options[key] || default_options[key] }
      define_method("#{key}=") { |value| @options[key] = value }
    end

    @options ||= {}

    def self.get_option(key)
      @options[key] || default_options[key]
    end

    def self.method_missing(name, *args, &block)
      if name =~ /^(\w+)=$/
        key = $1.to_sym
        if default_options.key? key
          define_method(name) { |value| @options[key] = value }
          return __send__ name, value
        end
      end
      super
    end

    def git(*args, &block)
      (@repos ||= {})[Dir.pwd] ||= Repository.new(Dir.pwd, *args, &block)
    end
  end

  def self.Easy(*args, &block)
    Easy::Repository.new *args, &block
  end
end
