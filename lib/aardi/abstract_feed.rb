# frozen_string_literal: true

module Aardi
  class AbstractFeed < AbstractBlog
    def initialize(posts, archive_path = nil, tag = nil)
      @archive_path = archive_path
      @posts = posts
      @tag = tag
    end

    def render
      write_target
    end

    def target_path
      return "./#{@archive_path}/#{feed_file}" if @archive_path

      "./#{feed_file}"
    end

    # Keep #title private so Nokogiri `:title` in ATOMFeed#feed_details
    # as an element name rather than a delegated call.
    private :title

    private

    def base_title = Aardi.config[:site_title]

    def children
      @posts
    end

    def creation = children.max_by(&:creation)&.creation

    def feed_url = "#{Aardi.config[:site_url]}#{target_path[1..]}"

    def updated = children.max_by(&:updated)&.updated

    def write_target
      source = Content.new(content)
      FileTarget.new(source, target_path).write
    end
  end
end
