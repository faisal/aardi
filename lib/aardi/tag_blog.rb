# frozen_string_literal: true

module Aardi
  class TagBlog < Blog
    # :reek:DuplicateMethodCall
    def initialize(tag)
      super()
      @tag = tag
      blog_archive_path = Aardi.config[:blog_archive_path]
      @blog_path = "#{blog_archive_path}/#{Aardi.config[:blog_tags_path]}/#{tag}"
      @archive_path = "#{@blog_path}/#{blog_archive_path}"
    end

    def <<(post)
      @posts << post
      archive << post
    end

    def count
      @posts.count
    end

    def index_line
      "- [#{tag}](#{url}) (#{count})"
    end

    def url
      "#{Aardi.config[:site_url]}/#{@blog_path}/"
    end

    private

    attr_reader :tag

    def archive_tag_index
      nil
    end

    def children
      [archive, home, atom_feed, json_feed]
    end
  end
end
