# frozen_string_literal: true

module Aardi
  class Renderer
    def initialize(config:)
      @custom_renderer = CustomRenderer.new
      @markup_renderer = Redcarpet::Markdown.new(@custom_renderer, config[:markup_options] || {})
    end

    def markup(content)
      @custom_renderer.reset
      @markup_renderer.render(content)
    end
  end
end
