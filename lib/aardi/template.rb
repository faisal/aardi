# frozen_string_literal: true

module Aardi
  # :reek:DataClump
  class Template
    PLACEHOLDER_MAIN = '__PLACEHOLDER_MAIN__'
    PLACEHOLDER_TITLE = '__PLACEHOLDER_TITLE__'
    PLACEHOLDER_DESCRIPTION = '__PLACEHOLDER_DESCRIPTION__'

    # :reek:FeatureEnvy
    def initialize(path)
      dom = Nokogiri::HTML5.parse(File.read(path).strip)
      dom.at_css('main').add_child(PLACEHOLDER_MAIN)
      dom.at_css('title').content += PLACEHOLDER_TITLE
      find_description(dom.at_css('meta[name="description"]'))
      @compiled = dom.to_html.strip
    end

    def render(src)
      result = @compiled.dup
      result.sub!(PLACEHOLDER_MAIN, Aardi.renderer.markup(src.content))
      result.sub!(PLACEHOLDER_TITLE, " #{text_escape(src.title)}")
      result.sub!(PLACEHOLDER_DESCRIPTION, description_value(src)) if @default_description
      result
    end

    private

    def description_value(src)
      escape_attributes(src.metadata.description || @default_description)
    end

    def escape_attributes(str)
      str.gsub('&', '&amp;').gsub('"', '&quot;')
    end

    # :reek:FeatureEnvy
    def find_description(meta)
      return unless meta

      @default_description = meta['content'] || ''
      meta['content'] = PLACEHOLDER_DESCRIPTION
    end

    def text_escape(str)
      str.gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;')
    end
  end
end
