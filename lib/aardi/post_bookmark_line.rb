# frozen_string_literal: true

module Aardi
  class PostBookmarkLine
    def initialize(post, config:)
      @post = post
      @config = config
    end

    def to_s
      %(<span class="bookmark">[<a href="#{@post.url}">bookmark</a>]#{tag_links}</span>)
    end

    private

    def tag_links
      tags = @post.tags
      return '' unless tags&.any?

      " #{tags.map { |tag| %(<a href="#{tags_base_url}/#{tag}/">#{tag}</a>) }.join(', ')}"
    end

    def tags_base_url
      "#{@config[:site_url]}/#{@config[:blog_archive_path]}/#{@config[:blog_tags_path]}"
    end
  end
end
