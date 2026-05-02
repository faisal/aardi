# frozen_string_literal: true

module Aardi
  class Site < AbstractBlog
    def initialize(config:)
      @config = config
      @ledger = Ledger.new

      initialize_ledger

      @posts = Dir.glob("#{@config[:blog_posts_path]}/**/*.md")
                  .map { |path| Post.new(path, config: @config, ledger: @ledger) }
                  .sort_by(&:creation)
    end

    def blog
      Blog.new @posts, config: @config, ledger: @ledger
    end

    def render
      super
      @ledger[:content_hashes].write
      Orphanage.new(config: @config, ledger: @ledger).report
    end

    private

    def children
      [Folder.new('.', config: @config, ledger: @ledger), blog, @ledger[:sitemap]]
    end

    # rubocop:disable Metrics/AbcSize
    def initialize_ledger
      @ledger[:content_hashes] = ContentHashes.new(@config[:content_hashes_path])
      @ledger[:custom_renderer] = CustomRenderer.new
      @ledger[:markdown_renderer] = Redcarpet::Markdown.new(@ledger[:custom_renderer], @config[:markup_options])
      @ledger[:html_files] = Dir.glob('./**/*.html').to_set
      @ledger[:sitemap] = Sitemap.new(config: @config, ledger: @ledger)
      @ledger[:template] = Template.new(@config[:template_path], ledger: @ledger)
    end
    # rubocop:enable Metrics/AbcSize

    def write_target; end
  end
end
