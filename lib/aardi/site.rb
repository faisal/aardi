# frozen_string_literal: true

module Aardi
  class Site < AbstractBlog
    def initialize
      initialize_ledger
    end

    # :reek:FeatureEnvy
    def blog
      config = Aardi.config
      @blog ||= Blog.new(config[:blog_posts_path], config[:blog_archive_path])
    end

    def render
      super
      content_hashes.write
      warn_about_orphans
    end

    private

    def children
      [Folder.new("."), blog, sitemap]
    end

    def content_hashes
      @content_hashes ||= ContentHashes.new(Aardi.config[:content_hashes_path])
    end

    def custom_renderer
      @custom_renderer ||= CustomRenderer.new
    end

    def html_files
      @html_files ||= Dir.glob("./**/*.html").to_set
    end

    def initialize_ledger
      ledger = Aardi.ledger
      # set up content hashes so they're in place while building out the rest
      ledger[:content_hashes] = content_hashes

      {custom_renderer:, markdown_renderer:, html_files:, sitemap:, template:}.each do |message, value|
        ledger[message] = value
      end
    end

    def markdown_renderer
      Redcarpet::Markdown.new(custom_renderer, Aardi.config[:markup_options])
    end

    def sitemap
      @sitemap ||= Sitemap.new
    end

    def template
      Template.new Aardi.config[:template_path]
    end

    def warn_about_orphans
      Orphanage.new.warn
    end

    def write_target
    end
  end
end
