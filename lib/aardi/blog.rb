# frozen_string_literal: true

module Aardi
  # :reek:TooManyInstanceVariables
  class Blog < AbstractBlog
    def initialize
      @posts = []
      @draft_posts = []
      @blog_path = nil
      @archive_path = Config[:blog_archive_path]
      @tags = Tags.new
    end

    def <<(post)
      return @draft_posts << post if post.draft?

      @posts << post
      archive << post
      @tags << post
    end

    def report_drafts
      report_posts @draft_posts
    end

    def report_recent
      report_posts recent_posts(:blog_recent_posts)
    end

    def tag_blogs = @tags.tag_blogs

    private

    def archive
      @archive ||= Archive.new(@archive_path, tag, @tags)
    end

    def atom_feed
      ATOMFeed.new(feed_posts, @blog_path, tag)
    end

    def children
      [archive, home, atom_feed, json_feed, *@tags, *@draft_posts]
    end

    def feed_posts
      recent_posts(:blog_feed_posts)
    end

    def home
      Home.new(recent_posts(:blog_home_posts), @archive_path, @blog_path, tag)
    end

    def json_feed
      JSONFeed.new(feed_posts, @blog_path, tag)
    end

    def recent_posts(conf_key)
      @posts.max_by(Config[conf_key], &:creation)
    end

    def report_posts(posts)
      posts.each(&:report_field_summary)
    end

    def tag = nil

    def write_target = {}
  end
end
