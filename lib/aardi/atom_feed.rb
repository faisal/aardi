# frozen_string_literal: true

module Aardi
  class ATOMFeed < AbstractFeed
    def content
      atom_feed = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do
        feed('xmlns' => 'http://www.w3.org/2005/Atom') do |feed|
          feed_details(feed)
        end
      end

      atom_feed.to_xml
    end

    # :reek:TooManyStatements
    # rubocop:disable Metrics/MethodLength
    def feed_details(feed)
      aardi_config = Aardi.config

      feed.author do
        name(aardi_config[:site_author])
      end

      subnodes = { id: feed_url, link: { href: feed_url, rel: 'self' },
                   title: aardi_config[:site_title], updated: updated.iso8601 }

      subnodes.each do |node, value|
        feed.public_send node, value
      end

      @posts.each do |post|
        post_details(post, feed)
      end
    end
    # rubocop:enable Metrics/MethodLength

    private

    def feed_file
      'index.xml'
    end

    # :reek:FeatureEnvy
    # :reek:TooManyStatements
    def post_details(post, feed)
      feed.entry do
        post_url = post.url

        # For safety, must use content_ and not content:
        content_(post.feed_snippet).type = 'html'

        subnodes = { id: post_url, link: { href: post_url }, title: post.title,
                     published: post.creation.iso8601, updated: post.updated.iso8601 }
        subnodes.each do |node, value|
          feed.public_send node, value
        end
      end
    end
  end
end
