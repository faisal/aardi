# frozen_string_literal: true

module Aardi
  # :reek:TooManyInstanceVariables
  class Renderer
    attr_reader :content_hashes, :html_files, :sitemap

    # :reek:ControlParameter
    def initialize(html_files: nil, content_hashes: nil, sitemap: nil)
      config = Aardi.config
      @html_files = html_files || Dir.glob('./**/*.html').to_set
      @content_hashes = content_hashes || ContentHashes.new(config[:content_hashes_path])
      @sitemap = sitemap || Sitemap.new
      @template = Template.new(config[:template_path])
      @custom_renderer = CustomRenderer.new
      @markup_renderer = Redcarpet::Markdown.new(@custom_renderer, config[:markup_options] || {})
    end

    def finalize(result)
      content_hashes.save(result)
      Orphanage.new.report(html_files, result.keys)
    end

    def markup(content)
      @custom_renderer.reset
      @markup_renderer.render(content)
    end

    def markup_feed_snippet(content)
      markup(content.sub(/\A(### .*\n)?\n+/, '')).strip
    end

    def render(src)
      @template.render(src)
    end
  end
end
