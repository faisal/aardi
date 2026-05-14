# frozen_string_literal: true

module Aardi
  class TagBlog < Blog
    # :reek:DuplicateMethodCall
    def initialize(tag)
      super()
      @tag = tag
      @blog_path = "#{Aardi.config[:blog_tags_path]}/#{tag}"
      @archive_path = "#{@blog_path}/#{Aardi.config[:blog_archive_path]}"
    end

    def <<(post)
      @posts << post
      archive << post
    end

    def count
      @posts.count
    end

    def index_line
      "- #{inline_link_text}"
    end

    def inline_link_text
      "[#{tag}](#{url}) (#{count})"
    end

    def url
      "#{Aardi.config[:site_url]}/#{@blog_path}/"
    end

    private

    attr_reader :tag

    def children
      [archive, home, atom_feed, json_feed]
    end
  end
end
