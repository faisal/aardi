# frozen_string_literal: true

require 'spec_helper'

class JSONFeedSpec < Minitest::Spec
  describe Aardi::JSONFeed do
    before do
      @config = setup_config
      @ledger = Aardi::Ledger.new
    end

    def make_feed(posts = [])
      Aardi::JSONFeed.new(posts, config: @config, ledger: @ledger)
    end

    describe '#target_path' do
      it 'is ./index.json' do
        _(make_feed.target_path).must_equal './index.json'
      end
    end

    describe '#content' do
      def parsed(posts = [StubPost.new(Time.now)])
        JSON.parse(make_feed(posts).content)
      end

      it 'uses JSON Feed version 1.1' do
        _(parsed['version']).must_equal 'https://jsonfeed.org/version/1.1'
      end

      it 'includes the site title' do
        _(parsed['title']).must_equal 'Test Site'
      end

      it 'includes the home_page_url' do
        _(parsed['home_page_url']).must_equal 'http://example.com'
      end

      it 'includes the feed_url pointing to index.json' do
        _(parsed['feed_url']).must_equal 'http://example.com/index.json'
      end

      it 'includes an item for each post' do
        posts = [StubPost.new(Time.now, title: 'Alpha'), StubPost.new(Time.now, title: 'Beta')]
        items = parsed(posts)['items']
        titles = items.map { |item| item['title'] }

        _(titles).must_include 'Alpha'
        _(titles).must_include 'Beta'
      end

      it 'item includes required fields: id, url, title, date_published, content_html' do
        item = parsed.dig('items', 0)
        %w[id url title date_published content_html].each do |field|
          _(item).must_include field
        end
      end

      it 'omits date_modified when creation equals updated' do
        post = StubPost.new(Time.now)
        item = parsed([post]).dig('items', 0)

        _(item).wont_include 'date_modified'
      end

      it 'includes date_modified when updated differs from creation' do
        post = StubPost.new(Time.now)
        def post.updated = Time.now
        item = parsed([post]).dig('items', 0)

        _(item).must_include 'date_modified'
      end
    end
  end
end
