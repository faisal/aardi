# frozen_string_literal: true

module Aardi
  class Site < AbstractBlog
    # rubocop:disable Metrics/AbcSize
    def initialize
      @config = Aardi.config
      @ledger = Aardi.ledger

      # set up content hashes so they're in place while building out the rest
      @ledger[:content_hashes] = ContentHashes.new @config[:content_hashes_path]

      @ledger[:custom_renderer] = CustomRenderer.new
      @ledger[:markdown_renderer] = Redcarpet::Markdown.new @ledger[:custom_renderer], @config[:markup_options]
      @ledger[:html_files] = Dir.glob('./**/*.html').to_set
      @ledger[:sitemap] = Sitemap.new
      @ledger[:template] = Template.new @config[:template_path]

      @posts = Dir.glob("#{@config[:blog_posts_path]}/**/*.md").map { |path| Post.new(path) }.sort_by(&:creation)
    end
    # rubocop:enable Metrics/AbcSize

    def blog
      Blog.new @posts
    end

    def render
      super
      @ledger[:content_hashes].write
      warn_about_orphans
    end

    private

    def children
      [Folder.new('.'), blog, @ledger[:sitemap]]
    end

    def warn_about_orphans
      Orphanage.new.report
    end

    def write_target; end
  end
end
