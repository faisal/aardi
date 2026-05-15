# frozen_string_literal: true

module Aardi
  class AbstractBlog
    attr_reader :key

    def metadata = (@metadata ||= Metadata.new)

    def mtime = children.max_by(&:mtime)&.mtime

    def render
      children.each(&:render)
      write_target
    end

    def title
      return "#{base_title} - #{@tag}" if @tag

      base_title
    end

    private

    def children
      []
    end

    def write_target
      source = PageContent.new content, title, metadata
      PageTarget.new(source, target_path).write
    end
  end
end
