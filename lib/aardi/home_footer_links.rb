# frozen_string_literal: true

module Aardi
  class HomeFooterLinks
    def initialize(blog_path)
      @blog_path = blog_path
    end

    def to_s
      "**More:** [Archive](#{archive_url}), [RSS](#{rss_url}), [JSON](#{json_url})"
    end

    private

    def archive_url  = "#{base_url}/#{Config[:blog_archive_path]}/"
    def base_url     = "#{Config[:site_url]}#{feed_base}"
    def feed_base    = @blog_path ? "/#{@blog_path}" : ''
    def json_url     = "#{base_url}/index.json"
    def rss_url      = "#{base_url}/index.xml"
  end
end
