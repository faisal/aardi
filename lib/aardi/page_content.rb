# frozen_string_literal: true

module Aardi
  class PageContent < Content
    attr_reader :title, :metadata

    def initialize(src_content, title, renderer, metadata = Metadata.new)
      super(src_content)
      @title = title
      @renderer = renderer
      @metadata = metadata
    end

    def content
      @src_content
    end

    def output
      @output ||= @renderer.render(self)
    end
  end
end
