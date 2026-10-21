# frozen_string_literal: true

module Aardi
  module Deprecation
    @warned = Set.new

    def self.caller_prefix
      location = caller_locations.find { |loc| !loc.path.start_with?(__dir__) }
      location ? "#{location.path}:#{location.lineno}: " : ''
    end
    private_class_method :caller_prefix

    def self.warn_once(shim, user, replacement)
      return unless @warned.add?([shim, user])

      warn("#{caller_prefix}warning: #{shim} is deprecated and will be removed in a future release; " \
           "use #{replacement} instead.")
    end
  end
end
