# frozen_string_literal: true

module Aardi
  # :reek:DataClump
  class Template
    def initialize(path)
      @path = path
      @content = File.read(path).strip
      @dom = Nokogiri::HTML5.parse(@content)
    end

    def render(src, renderer)
      dom = @dom.clone

      add_main(dom, src, renderer)
      add_title(dom, src)
      add_description(dom, src)

      dom.to_html.strip
    end

    private

    def add_description(dom, src)
      description = src.metadata.description
      return unless description

      dom.at_css('meta[name="description"]')['content'] = description
    end

    def add_main(dom, src, renderer)
      dom.at_css('main').add_child(renderer.markup(src.content))
    end

    def add_title(dom, src)
      dom.at_css('title').content += " #{src.title}"
    end
  end
end
