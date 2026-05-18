# frozen_string_literal: true

module Aardi
  # :reek:TooManyInstanceVariables
  class Renderer
    attr_reader :content_hashes, :html_files, :sitemap

    def initialize(html_files, content_hashes, sitemap)
      config = Aardi.config
      @html_files = html_files
      @content_hashes = content_hashes
      @sitemap = sitemap
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
