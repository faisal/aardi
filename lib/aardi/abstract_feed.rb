# frozen_string_literal: true

module Aardi
  class AbstractFeed < Feed
    def self.new(...)
      Deprecation.warn_once(AbstractFeed, self, 'Aardi::Feed')
      super
    end
  end
end
