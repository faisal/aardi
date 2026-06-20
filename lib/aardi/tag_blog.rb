# frozen_string_literal: true

module Aardi
  class TagBlog < Blog
    # :reek:DuplicateMethodCall
    def initialize(tag)
      super()
      @tag = tag
      @blog_path = "#{Config[:blog_tags_path]}/#{tag}"
      @archive_path = "#{@blog_path}/#{Config[:blog_archive_path]}"
    end

    def <<(post)
      @posts << post
      archive << post
    end

    def count
      @posts.count
    end

    def feed_menu_item
      { 'feed-title' => title,
        'rss' => "/#{@blog_path}/#{ATOMFeed::FEED_FILE}",
        'json' => "/#{@blog_path}/#{JSONFeed::FEED_FILE}" }
    end

    def index_line
      "- #{inline_link_text}"
    end

    def inline_link_text
      "[#{tag}](#{url}) (#{count})"
    end

    def url
      "#{Config[:site_url]}/#{@blog_path}/"
    end

    private

    attr_reader :tag

    def children
      [archive, home, feed(ATOMFeed), feed(JSONFeed)]
    end
  end
end
