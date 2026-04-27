# frozen_string_literal: true

module Aardi
  # :reek:TooManyStatements
  class Home < AbstractBlog
    # :reek:LongParameterList
    # rubocop:disable Metrics/ParameterLists
    def initialize(posts, archive_path, config:, ledger:, blog_path: nil, tag: nil)
      super(config:, ledger:)
      @posts = posts
      @archive_path = archive_path
      @blog_path = blog_path
      @tag = tag
    end
    # rubocop:enable Metrics/ParameterLists

    def content
      "# #{title}\n#{post_days_content}#{content_footer}"
    end

    def render
      @ledger[:sitemap].update_mtime('/', mtime) unless @blog_path
      write_target
    end

    def target_path
      return "./#{@blog_path}/index.html" if @blog_path

      './index.html'
    end

    def title
      base_title = @config[:blog_home_title]
      return "#{base_title} - #{@tag}" if @tag

      base_title
    end

    private

    def children
      @posts
    end

    # :reek:NilCheck
    def content_footer
      site_url = @config[:site_url]
      feed_base = @blog_path.nil? ? '' : "/#{@blog_path}"
      archive_url = "#{site_url}#{feed_base}/#{@config[:blog_archive_path]}/"
      rss_url = "#{site_url}#{feed_base}/index.xml"
      json_url = "#{site_url}#{feed_base}/index.json"
      "**More:** [Archive](#{archive_url}), [RSS](#{rss_url}), [JSON](#{json_url})"
    end

    def days_hash
      @days_hash ||= @posts.group_by { |post| post.creation.strftime('%Y-%m-%d') }
    end

    def post_day_content(post_day)
      "## #{post_day.first.creation.strftime('%A, %e %B %Y')}\n#{post_day.map(&:content).join}"
    end

    def post_days_content
      days_hash.values.map { |day| post_day_content(day) }.join
    end
  end
end
