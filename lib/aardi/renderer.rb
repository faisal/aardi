# frozen_string_literal: true

module Aardi
  class Renderer
    def initialize
      config = Aardi.config
      @template = Template.new(config[:template_path])
      @custom_renderer = CustomRenderer.new
      @markup_renderer = Redcarpet::Markdown.new(@custom_renderer, config[:markup_options] || {})
    end

    def markup(content)
      @custom_renderer.reset
      @markup_renderer.render(content)
    end

    def markup_feed_snippet(content)
      markup(content.sub(/\A(### .*\n)?\n+/, '')).strip
    end

    def render(src)
      @template.render(src, self)
    end
  end
end
