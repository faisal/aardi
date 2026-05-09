# frozen_string_literal: true

module Aardi
  class Config
    def initialize
      @data = {}
    end

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
      @data.freeze
      self
    end
  end
end
