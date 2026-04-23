# frozen_string_literal: true

module Aardi
  # :reek:DataClump
  class Template
    def initialize(path, ledger:)
      @path = path
      @ledger = ledger
      @content = File.read(path).strip
      @dom = Nokogiri::HTML5.parse(@content)
    end

    # :reek:TooManyStatements
    def render(src)
      @ledger[:custom_renderer].reset
      dom = @dom.clone

      add_main(dom, src)
      add_title(dom, src)
      add_description(dom, src)

      dom.to_html.strip
    end

    private

    def add_description(dom, src)
      description = src.metadata['Description']
      return unless description

      dom.at_css('meta[name="description"]')['content'] = description
    end

    def add_main(dom, src)
      dom.at_css('main').add_child(@ledger[:markdown_renderer].render(src.content))
    end

    def add_title(dom, src)
      dom.at_css('title').content += " #{src.title}"
    end
  end
end
