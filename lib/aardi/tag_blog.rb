# frozen_string_literal: true

module Aardi
  class TagBlog < Blog
    def initialize(posts, tag, config:, ledger:)
      super(posts, config:, ledger:)
      @tag = tag
      blog_archive_path = @config[:blog_archive_path]
      @blog_path = "#{blog_archive_path}/#{@config[:blog_tags_path]}/#{tag}"
      @archive_path = "#{@blog_path}/#{blog_archive_path}"
    end

    private

    attr_reader :tag

    def archive_tag_index = nil

    def children
      [archive, home, atom_feed, json_feed]
    end

    def scoped_calendar = @posts.calendar_for(@tag)

    def scoped_list = @posts.list_for(@tag)
  end
end
