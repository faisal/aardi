# frozen_string_literal: true

module Aardi
  class Config
    def initialize
      @data = {}
    end

    def [](key) = @data[key]

    # :reek:TooManyStatements
    def load(path)
      config_hash = YAML.safe_load_file(path)
      config_hash.transform_keys!(&:to_sym)
      config_hash[:markup_options]&.transform_keys!(&:to_sym)
      @data.merge!(config_hash)
      @data.freeze
      self
    end
  end
end
