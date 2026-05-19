# frozen_string_literal: true

module Aardi
  class Site < AbstractBlog
    def initialize
      posts.each do |post|
        blog << post
      end
    end

    def blog
      @blog ||= Blog.new
    end

    def render
      Aardi.renderer.finalize(super)
    end

    private

    def children
      [Folder.new('.'), blog, Aardi.renderer.sitemap]
    end

    def post_paths
      Dir.glob("#{Config[:blog_posts_path]}/**/*.md")
    end

    def posts
      post_paths.map { |path| Post.new(path) }
    end

    def write_target = {}
  end
end
