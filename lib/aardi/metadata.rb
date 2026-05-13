# frozen_string_literal: true

module Aardi
  class Metadata
    KNOWN_KEYS = %w[Title Description Creation Updated Tags].freeze

    def self.parse(yaml_str, source: nil)
      yaml = YAML.safe_load(yaml_str, permitted_classes: [Time])
      return new({}, source) unless yaml.is_a?(Hash)

      new(yaml, source)
    end

    def initialize(yaml, source = nil)
      @yaml = yaml
      warn_unknown(source)
    end

    def creation    = @yaml['Creation']
    def description = @yaml['Description']
    def empty?      = @yaml.empty?
    def tags        = @yaml['Tags']&.split&.sort
    def title       = @yaml['Title']
    def updated     = @yaml['Updated']

    private

    def location_hint(source)
      return '' unless source

      " in #{source}"
    end

    def warn_unknown(source)
      unknown = @yaml.keys - KNOWN_KEYS
      return if unknown.empty?

      unknown.each { |key| warn "Aardi::Metadata: unknown declaration '#{key}'#{location_hint(source)} (ignored)" }
    end
  end
end
