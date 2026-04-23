# frozen_string_literal: true

module Aardi
  class Home < AbstractBlog
    def initialize(posts, archive_path, config:, ledger:)
      super(config:, ledger:)
      @posts = posts
      @archive_path = archive_path
    end

    def content
      "# #{title}\n#{post_days_content}#{content_footer}"
    end

    def render
      @ledger[:sitemap].update_mtime('/', mtime)
      write_target
    end

    def target_path = './index.html'

    def title = @config[:blog_home_title]

    private

    def children
      @posts
    end

    def content_footer
      site_url = @config[:site_url]
      more_archive = "[Archive](#{site_url}/#{@archive_path}/)"
      more_rss = "[RSS](#{site_url}/index.xml)"
      more_json = "[JSON](#{site_url}/index.json)"
      "**More:** #{more_archive}, #{more_rss}, #{more_json}"
    end

    def days_hash
      @days_hash ||= @posts.group_by { |post| post.creation.strftime('%Y-%m-%d') }
    end

    def post_day_content(post_day)
      date_header = post_day.first.creation.strftime('%A, %e %B %Y')
      posts_content = post_day.map(&:content).join
      "## #{date_header}\n#{posts_content}"
    end

    def post_days_content
      days_hash.values.map { |day| post_day_content(day) }.join
    end
  end
end
