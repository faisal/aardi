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
      save_content_hashes(@result)
      report_orphans(@result)
    end

    private

    def children
      [Folder.new('.'), blog, Aardi.ledger[:sitemap]]
    end

    # :reek:DuplicateMethodCall
    def initialize_ledger
      ledger = Aardi.ledger
      ledger[:content_hashes] = ContentHashes.new(Aardi.config[:content_hashes_path])
      ledger[:renderer] = Renderer.new
      ledger[:html_files] = Dir.glob('./**/*.html').to_set
      ledger[:sitemap] = Sitemap.new
    end

    def posts
      Dir.glob("#{Aardi.config[:blog_posts_path]}/**/*.md")
         .map { |path| Post.new(path) }
    end

    def report_orphans(result)
      Orphanage.new.report(Aardi.ledger[:html_files], result.keys)
    end

    def save_content_hashes(result)
      Aardi.ledger[:content_hashes].save(result)
    end

    def write_target = {}
  end
end
