# frozen_string_literal: true

module Aardi
  class Tags < AbstractBlog
    def initialize
      @index = Hash.new { |hash, tag| hash[tag] = TagBlog.new(tag) }
    end

    def <<(post)
      post.tags&.each do |tag|
        @index[tag] << post
      end
    end

    def archive_tag_index = self

    def content
      return "# Tags\n" if counts.empty?

      "# Tags\n\n#{tag_lines.join("\n")}\n"
    end

    def empty? = @index.empty?

    def inline_links
      counts.map { |tag, tag_blog| "[#{tag}](#{tag_blog.url})" }.join(', ')
    end

    def target_path
      "./#{tags_base_path}/index.html"
    end

    def title = 'Tags'

    private

    def children
      @index.values
    end

    def counts
      sorted_index
    end

    def sorted_index
      @sorted_index ||= @index.sort_by { |_key, tag_blog| tag_blog.count }.reverse.to_h
    end

    def tag_lines
      sorted_index.map { |_tag, tag_blog| tag_blog.index_line }
    end

    def tags_base_path
      Aardi.config[:blog_tags_path]
    end

    def write_target
      return if empty?

      super
    end
  end
end
