# frozen_string_literal: true

module Aardi
  class Config
    @data = {}

    class << self
      def [](key) = @data[key]

      def load(path)
        config_yaml = File.read path
        prepare config_yaml
      end

      # :reek:TooManyStatements
      def prepare(config_yaml)
        config_hash = YAML.safe_load config_yaml
        config_hash.transform_keys!(&:to_sym)
        config_hash[:markup_options]&.transform_keys!(&:to_sym)
        @data.merge!(config_hash)
        @data.default_proc = ->(_, key) { raise KeyError, "Key not found: #{key.inspect}" }
        @data.freeze
        self
      end

      def reset
        @data = {}
      end
    end
  end
end
