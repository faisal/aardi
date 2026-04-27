# frozen_string_literal: true

module Aardi
  class AbstractFeed < AbstractBlog
    def initialize(posts, config:, ledger:, archive_path: nil, tag: nil)
      super(config:, ledger:)
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

    private

    def children
      @posts
    end

    def creation = children.max_by(&:creation)&.creation

    def feed_title
      base_title = @config[:site_title]
      return "#{base_title} - #{@tag}" if @tag

      base_title
    end

    def feed_url = "#{@config[:site_url]}#{target_path[1..]}"

    def updated = children.max_by(&:updated)&.updated

    def write_target
      source = Content.new(content)
      FileTarget.new(source, target_path, ledger: @ledger).write
    end
  end
end
