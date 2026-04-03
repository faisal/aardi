# frozen_string_literal: true

module Aardi
  class Blog < AbstractBlog
    def initialize(posts_path, archive_path)
      @posts_path = posts_path
      @archive_path = archive_path
    end

    def posts
      @posts ||= Dir.glob("#{@posts_path}/**/*.md").map { |post_path| Post.new(post_path) }.sort_by(&:creation)
    end

    def report_recent
      recent_posts(:blog_recent_posts).each(&:report_field_summary)
    end

    private

    def archive
      Archive.new(posts, @archive_path)
    end

    def atom_feed
      ATOMFeed.new(feed_posts)
    end

    def children
      [archive, home, atom_feed, json_feed]
    end

    def feed_posts
      recent_posts(:blog_feed_posts)
    end

    def home
      Home.new(recent_posts(:blog_home_posts), @archive_path)
    end

    def json_feed
      JSONFeed.new(feed_posts)
    end

    def recent_posts(conf_key)
      posts.last(Aardi.config[conf_key]).reverse
    end

    def write_target = nil
  end
end
