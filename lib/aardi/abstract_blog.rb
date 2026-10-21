# frozen_string_literal: true

module Aardi
  class AbstractBlog
    include Renderable

    def self.new(...)
      Deprecation.warn_once(AbstractBlog, self, 'Aardi::Renderable')
      super
    end
  end
end
