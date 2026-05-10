# frozen_string_literal: true

module Aardi
  class Metadata
    KNOWN_KEYS = %w[Title Description Creation Updated Tags].freeze

    def self.parse(yaml_str, source: nil)
      raw = YAML.safe_load(yaml_str, permitted_classes: [Time])
      new(raw.is_a?(Hash) ? raw : {}, source)
    end

    def initialize(raw, source = nil)
      @raw = raw
      warn_unknown(source)
    end

    def creation    = @raw['Creation']
    def description = @raw['Description']
    def empty?      = @raw.empty?
    def tags        = @raw['Tags']&.split&.sort
    def title       = @raw['Title']
    def updated     = @raw['Updated']

    private

    def location_hint(source) = source ? " in #{source}" : ''

    def warn_unknown(source)
      unknown = @raw.keys - KNOWN_KEYS
      return if unknown.empty?

      unknown.each { |key| warn "Aardi::Metadata: unknown declaration '#{key}'#{location_hint(source)} (ignored)" }
    end
  end
end
