# frozen_string_literal: true

module Aardi
  class Config
    def initialize(path = './config.yml')
      @data = prepare(YAML.safe_load_file(path))
    end

    def [](key) = @data[key]

    private

    def prepare(config_hash)
      config_hash.transform_keys!(&:to_sym)
      config_hash[:markup_options]&.transform_keys!(&:to_sym)
      config_hash.freeze
    end
  end
end
