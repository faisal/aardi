# frozen_string_literal: true

module Aardi
  class TagIndex < AbstractBlog
    def initialize(tag_counts)
      @tag_counts = tag_counts
    end

    def content
      return "# Tags\n" if @tag_counts.empty?

      "# Tags\n\n#{tag_lines.join("\n")}\n"
    end

    def empty? = @tag_counts.empty?

    def inline_links
      tag_list.map { |tag| "[#{tag}](#{tag_url(tag)})" }.join(', ')
    end

    def target_path
      "./#{tags_base_path}/index.html"
    end

    def title = 'Tags'

    private

    def tag_lines
      @tag_counts.sort.map { |tag, count| "- [#{tag}](#{tag_url(tag)}) (#{count})" }
    end

    def tag_list
      @tag_counts.keys.sort
    end

    def tag_url(tag)
      "#{Aardi.config[:site_url]}/#{tags_base_path}/#{tag}/"
    end

    def tags_base_path
      config = Aardi.config
      "#{config[:blog_archive_path]}/#{config[:blog_tags_path]}"
    end
  end
end
