# frozen_string_literal: true

module Aardi
  class Site < AbstractBlog
    def initialize
      initialize_ledger

      posts.each do |post|
        blog << post
      end
    end

    def blog
      @blog ||= Blog.new
    end

    def render
      super
      Aardi.ledger[:content_hashes].write
      Orphanage.new.report
    end

    private

    def children
      [Folder.new('.'), blog, Aardi.ledger[:sitemap]]
    end

    # rubocop:disable Metrics/AbcSize
    # :reek:DuplicateMethodCall
    def initialize_ledger
      ledger = Aardi.ledger
      ledger[:content_hashes] = ContentHashes.new(Aardi.config[:content_hashes_path])
      ledger[:renderer] = Renderer.new
      ledger[:html_files] = Dir.glob('./**/*.html').to_set
      ledger[:sitemap] = Sitemap.new
      ledger[:template] = Template.new(Aardi.config[:template_path])
    end
    # rubocop:enable Metrics/AbcSize

    def posts
      Dir.glob("#{Aardi.config[:blog_posts_path]}/**/*.md")
         .map { |path| Post.new(path) }
    end

    def write_target; end
  end
end
