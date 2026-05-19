# frozen_string_literal: true

module Aardi
  class PostBookmarkLine
    def initialize(post)
      @post = post
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
      "#{Config[:site_url]}/#{Config[:blog_tags_path]}"
    end
  end
end
