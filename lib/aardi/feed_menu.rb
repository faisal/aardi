# frozen_string_literal: true

module Aardi
  class FeedMenu
    def initialize(blog)
      @blog = blog
    end

    def content
      JSON.pretty_generate(menu_data)
    end

    def render
      source = Content.new(content)
      FileTarget.new(source, target_path).write
    end

    def target_path = './.well-known/feed-menu.json'

    private

    def items = [site_item, *tag_items]

    def menu_data = { 'feed-menu' => site_title, 'items' => items }

    def site_item
      { 'feed-title' => site_title,
        'rss' => "/#{ATOMFeed::FEED_FILE}",
        'json' => "/#{JSONFeed::FEED_FILE}" }
    end

    def site_title = Config[:site_title]

    def tag_items = @blog.tag_blogs.map(&:feed_menu_item)
  end
end
