# frozen_string_literal: true

module Aardi
  class TagBlog < Blog
    def initialize(tag, config:, ledger:)
      super(config:, ledger:)
      @tag = tag
      blog_archive_path = @config[:blog_archive_path]
      @blog_path = "#{blog_archive_path}/#{@config[:blog_tags_path]}/#{tag}"
      @archive_path = "#{@blog_path}/#{blog_archive_path}"
    end

    def <<(post)
      @posts << post
      archive << post
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
