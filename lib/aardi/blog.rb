# frozen_string_literal: true

module Aardi
  # :reek:TooManyMethods
  class Blog < AbstractBlog
    def initialize(posts, config:, ledger:)
      super(config:, ledger:)
      @posts = posts
      @blog_path = nil
      @archive_path = @config[:blog_archive_path]
    end

    def report_recent
      recent_posts(:blog_recent_posts).each(&:report_field_summary)
    end

    private

    def archive
      Archive.new(@posts, @archive_path, config: @config, ledger: @ledger, tag: tag, tag_index: archive_tag_index)
    end

    def archive_tag_index
      tag_index unless tag_groups.empty?
    end

    def atom_feed
      ATOMFeed.new(feed_posts, config: @config, ledger: @ledger, archive_path: @blog_path, tag: tag)
    end

    def children
      [archive, home, atom_feed, json_feed, *tag_children]
    end

    def feed_posts
      recent_posts(:blog_feed_posts)
    end

    def group_post_by_tags(post, groups)
      post.tags&.each { |tag| (groups[tag] ||= []) << post }
    end

    def home
      Home.new(recent_posts(:blog_home_posts), @archive_path, config: @config, ledger: @ledger, blog_path: @blog_path,
                                                              tag: tag)
    end

    def json_feed
      JSONFeed.new(feed_posts, config: @config, ledger: @ledger, archive_path: @blog_path, tag: tag)
    end

    def recent_posts(conf_key)
      @posts.last(@config[conf_key]).reverse
    end

    def tag = nil

    def tag_children
      return [] if tag_groups.empty?

      [tag_index, *tag_groups.map { |tag, posts| TagBlog.new(posts, tag, config: @config, ledger: @ledger) }]
    end

    def tag_groups
      @tag_groups ||= @posts.each_with_object({}) { |post, groups| group_post_by_tags(post, groups) }
    end

    def tag_index
      @tag_index ||= TagIndex.new(tag_groups.transform_values(&:size), config: @config, ledger: @ledger)
    end

    def write_target = nil
  end
end
