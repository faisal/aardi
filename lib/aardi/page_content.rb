# frozen_string_literal: true

module Aardi
  class PageContent < Content
    attr_reader :title, :metadata

    def initialize(src_content, title, metadata = {}, ledger:)
      super(src_content)
      @title = title
      @metadata = metadata
      @ledger = ledger
    end

    def content
      @src_content
    end

    def output
      @output ||= @ledger[:template].render(self)
    end
  end
end
