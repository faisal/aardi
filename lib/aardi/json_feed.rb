# frozen_string_literal: true

module Aardi
  class JSONFeed < AbstractFeed
    def content
      aardi_config = Aardi.config
      feed_content = { version: 'https://jsonfeed.org/version/1.1', title: aardi_config[:site_title],
                       home_page_url: aardi_config[:site_url], feed_url: }
      feed_content[:items] = @posts.map { |post| post_details(post) }

      JSON.pretty_generate(feed_content)
    end

    private

    def feed_file
      'index.json'
    end

    def post_details(post)
      post_updated = post.updated
      post_creation = post.creation

      details = { id: post.name, url: post.url, title: post.title,
                  date_published: post_creation.iso8601, content_html: post.feed_snippet }

      details[:date_modified] = post_updated.iso8601 unless post_creation == post_updated

      details
    end
  end
end
