# frozen_string_literal: true

module Aardi
  class Page
    include AbstractPageSupport

    def initialize(path, ledger:)
      @path = path
      @ledger = ledger
      parse_source path
    end

    def content
      @src_content
    end

    def render
      page_content = PageContent.new(content, title, metadata, ledger: @ledger)
      PageTarget.new(page_content, target_path, ledger: @ledger).write
    end

    def target_path
      @path.pathmap('%X.html')
    end
  end
end
