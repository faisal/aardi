# frozen_string_literal: true

module Aardi
  class AbstractBlog
    attr_reader :key

    def initialize(config:, ledger:)
      @config = config
      @ledger = ledger
    end

    def metadata = (@metadata ||= {})

    def mtime = children.max_by(&:mtime)&.mtime

    def render
      children.each(&:render)
      write_target
    end

    private

    def children
      []
    end

    def write_target
      source = PageContent.new content, title, metadata, ledger: @ledger
      PageTarget.new(source, target_path, ledger: @ledger).write
    end
  end
end
