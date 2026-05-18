# frozen_string_literal: true

module Aardi
  class Page
    include AbstractPageSupport

    def initialize(path)
      @path = path
      parse_source path
    end

    def content
      @src_content
    end

    def render(renderer)
      page_content = PageContent.new(content, title, renderer, metadata)
      PageTarget.new(page_content, target_path, renderer).write
    end

    def target_path
      @path.pathmap('%X.html')
    end
  end
end
