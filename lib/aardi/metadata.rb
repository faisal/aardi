# frozen_string_literal: true

module Aardi
  class Metadata
    KNOWN_KEYS = %w[Title Description Creation Updated Tags HomePriority TagPriority Draft].freeze

    def initialize(yaml_str = '', source = nil)
      yaml = YAML.safe_load(yaml_str, permitted_classes: [Time])
      @yaml = {}
      @yaml = yaml if yaml.is_a? Hash
      confirm_keys(source)
    end

    def creation    = @yaml['Creation']
    def description = @yaml['Description']
    def empty?      = @yaml.empty?
    def tags        = @yaml['Tags']&.split&.sort
    def title       = @yaml['Title']
    def updated     = @yaml['Updated']

    private

    def confirm_keys(source)
      unknown = @yaml.keys - KNOWN_KEYS
      return if unknown.empty?

      unknown.each { |key| warn "Ignored unknown declaration '#{key}'#{source_location(source)}" }
    end

    def source_location(source)
      return '' unless source

      " in #{source}"
    end
  end
end
