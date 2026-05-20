# frozen_string_literal: true

module Aardi
  class Config
    RAISE_ON_MISS = ->(_, key) { raise KeyError, "Key not found: #{key.inspect}" }

    @data = Hash.new(&RAISE_ON_MISS)

    class << self
      def [](key) = @data[key]
      def fetch(key, default = nil) = @data.fetch(key, default)
      def load(path) = prepare(File.read(path))

      def prepare(config_yaml)
        @data.merge!(YAML.safe_load(config_yaml).transform_keys(&:to_sym))
        @data.freeze
        self
      end

      def reset
        @data = Hash.new(&RAISE_ON_MISS)
      end
    end
  end
end
