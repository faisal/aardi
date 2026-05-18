# frozen_string_literal: true

module Aardi
  # :reek:TooManyInstanceVariables
  class Site < AbstractBlog
    def initialize
      @html_files = Dir.glob('./**/*.html').to_set
      @content_hashes = ContentHashes.new(Aardi.config[:content_hashes_path])
      @sitemap = Sitemap.new
      @renderer = Renderer.new(@html_files, @content_hashes, @sitemap)

      posts.each do |post|
        blog << post
      end
    end

    def blog
      @blog ||= Blog.new
    end

    def render
      result = super(@renderer)
      @content_hashes.save(result)
      Orphanage.new.report(@html_files, result.keys)
    end

    private

    def children
      [Folder.new('.'), blog, @sitemap]
    end

    def post_paths
      Dir.glob("#{Aardi.config[:blog_posts_path]}/**/*.md")
    end

    def posts
      post_paths.map { |path| Post.new(path, @renderer) }
    end

    def write_target(_renderer) = {}
  end
end
