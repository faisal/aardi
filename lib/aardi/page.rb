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

    def render
      page_content = PageContent.new(content, title, metadata)
      PageTarget.new(page_content, target_path, ledger: Aardi.ledger).write
    end

    def target_path
      @path.pathmap('%X.html')
    end
  end
end
