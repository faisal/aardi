# frozen_string_literal: true

module Aardi
  class Renderer
    def initialize
      @custom_renderer = CustomRenderer.new
      @markup_renderer = Redcarpet::Markdown.new(@custom_renderer, Aardi.config[:markup_options] || {})
    end

    def markup(content)
      @custom_renderer.reset
      @markup_renderer.render(content)
    end

    def markup_feed_snippet(content)
      markup(content.sub(/\A(### .*\n)?\n+/, '')).strip
    end
  end
end
