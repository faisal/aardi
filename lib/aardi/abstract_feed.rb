# frozen_string_literal: true

module Aardi
  class AbstractFeed < AbstractBlog
    def initialize(posts, config:, ledger:)
      super(config:, ledger:)
      @posts = posts
    end

    def render
      write_target
    end

    def target_path = "./#{feed_file}"

    private

    def children
      @posts
    end

    def creation = children.max_by(&:creation)&.creation

    def feed_url = "#{@config[:site_url]}/#{feed_file}"

    def updated = children.max_by(&:updated)&.updated

    def write_target
      source = Content.new(content)
      FileTarget.new(source, target_path, ledger: @ledger).write
    end
  end
end
