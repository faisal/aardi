# frozen_string_literal: true

module Aardi
  class PageContent < Content
    attr_reader :title, :metadata

    def initialize(src_content, title, metadata = {})
      super(src_content)
      @title = title
      @metadata = metadata
    end

    def content
      @src_content
    end

    def output
      @output ||= Aardi.ledger[:template].render(self)
    end
  end
end
