# frozen_string_literal: true

module Aardi
  class Site < AbstractBlog
    def initialize(config: Aardi.config)
      @config = config
      @ledger = Ledger.new
      initialize_ledger

      @posts = Dir.glob("#{@config[:blog_posts_path]}/**/*.md")
                  .map { |path| Post.new(path, config: @config, ledger: @ledger) }
                  .sort_by(&:creation)
    end

    def blog
      @blog ||= Blog.new @posts, config: @config, ledger: @ledger
    end

    def render
      super
      @ledger[:content_hashes].write
      warn_about_orphans
    end

    private

    def children
      [Folder.new('.', config: @config, ledger: @ledger), blog, sitemap]
    end

    def content_hashes
      @content_hashes ||= ContentHashes.new(@config[:content_hashes_path])
    end

    def custom_renderer
      @custom_renderer ||= CustomRenderer.new
    end

    def initialize_ledger
      @ledger[:content_hashes] = content_hashes
      @ledger[:custom_renderer] = custom_renderer
      @ledger[:markdown_renderer] = markdown_renderer
      @ledger[:html_files] = Dir.glob('./**/*.html').to_set
      @ledger[:sitemap] = sitemap
      @ledger[:template] = template
    end

    def markdown_renderer
      @markdown_renderer ||= Redcarpet::Markdown.new(custom_renderer, @config[:markup_options])
    end

    def sitemap
      @sitemap ||= Sitemap.new(config: @config, ledger: @ledger)
    end

    def template
      @template ||= Template.new(@config[:template_path], ledger: @ledger)
    end

    def warn_about_orphans
      Orphanage.new(config: @config, ledger: @ledger).report
    end

    def write_target; end
  end
end
