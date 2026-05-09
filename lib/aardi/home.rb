# frozen_string_literal: true

module Aardi
  # :reek:TooManyStatements
  # :reek:RepeatedConditional
  class Home < AbstractBlog
    def initialize(posts, archive_path, blog_path: nil, tag: nil)
      @posts = posts
      @archive_path = archive_path
      @blog_path = blog_path
      @tag = tag
    end

    def content
      "# #{title}\n#{post_days_content}#{content_footer}"
    end

    def render
      Aardi.ledger[:sitemap].update_mtime('/', mtime) unless @blog_path
      write_target
    end

    def target_path
      return "./#{@blog_path}/index.html" if @blog_path

      './index.html'
    end

    def title
      base_title = Aardi.config[:blog_home_title]
      return "#{base_title} - #{@tag}" if @tag

      base_title
    end

    private

    def children
      @posts
    end

    # :reek:NilCheck
    # :reek:DuplicateMethodCall
    def content_footer
      site_url = Aardi.config[:site_url]
      feed_base = "/#{@blog_path}" if @blog_path

      "**More:** \
[Archive](#{"#{site_url}#{feed_base}/#{Aardi.config[:blog_archive_path]}/"}), \
[RSS](#{"#{site_url}#{feed_base}/index.xml"}), \
[JSON](#{"#{site_url}#{feed_base}/index.json"})"
    end

    def days_hash
      @days_hash ||= @posts.group_by { |post| post.creation.strftime('%Y-%m-%d') }
    end

    def post_day_content(post_day)
      first_post = post_day.first
      "## #{first_post.creation.strftime('%A, %e %B %Y')}\n#{post_day.map(&:content).join}"
    end

    def post_days_content
      days_hash.values.map { |day| post_day_content(day) }.join
    end
  end
end
