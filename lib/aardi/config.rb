# frozen_string_literal: true

module Aardi
  class Config
    def initialize(path = './config.yml')
      @data = {}
      prepare File.read(path)
    end

    def [](key) = @data[key]

    private

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
