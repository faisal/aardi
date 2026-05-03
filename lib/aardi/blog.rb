# frozen_string_literal: true

module Aardi
  class Blog < AbstractBlog
    def initialize(config:, ledger:)
      super
      @posts = []
      @blog_path = nil
      @archive_path = @config[:blog_archive_path]
      @tags = BlogTagPages.new(config: config, ledger: ledger)
    end

    def <<(post)
      @posts << post
      archive << post
      @tags << post
    end

    def report_recent
      recent_posts(:blog_recent_posts).each(&:report_field_summary)
    end

    private

    def archive
      @archive ||= Archive.new(@archive_path, config: @config, ledger: @ledger, tag: tag,
                                              tag_index: @tags.archive_tag_index)
    end

    def atom_feed
      ATOMFeed.new(feed_posts, config: @config, ledger: @ledger, archive_path: @blog_path, tag: tag)
    end

    def children
      [archive, home, atom_feed, json_feed, *@tags.children]
    end

    def feed_posts
      recent_posts(:blog_feed_posts)
    end

    def home
      Home.new(recent_posts(:blog_home_posts), @archive_path, config: @config, ledger: @ledger,
                                                              blog_path: @blog_path, tag: tag)
    end

    def json_feed
      JSONFeed.new(feed_posts, config: @config, ledger: @ledger, archive_path: @blog_path, tag: tag)
    end

    def recent_posts(conf_key)
      @posts.max_by(@config[conf_key], &:creation)
    end

    def tag = nil

    def write_target = nil
  end
end
