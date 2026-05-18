# frozen_string_literal: true

module Aardi
  class AbstractBlog
    attr_reader :key

    def metadata = (@metadata ||= Metadata.new)

    def mtime = children.max_by(&:mtime)&.mtime

    def render(renderer)
      children.each_with_object({}) { |child, acc| acc.merge!(child.render(renderer)) }.merge!(write_target(renderer))
    end

    def title
      return "#{base_title} - #{@tag}" if @tag

      base_title
    end

    private

    def children
      []
    end

    def write_target(renderer)
      source = PageContent.new(content, title, renderer, metadata)
      PageTarget.new(source, target_path, renderer).write
    end
  end
end
