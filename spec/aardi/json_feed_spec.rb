# frozen_string_literal: true

require 'spec_helper'

class JSONFeedSpec < Minitest::Spec
  describe Aardi::JSONFeed do
    before do
      setup_config
    end

    def make_feed(posts = [])
      Aardi::JSONFeed.new(posts)
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

      describe 'with tag' do
        def make_feed_with_tag
          Aardi::JSONFeed.new([StubPost.new(Time.now)], nil, 'foo')
        end

        it 'includes tag in feed title' do
          _(JSON.parse(make_feed_with_tag.content)['title']).must_equal 'Test Site - foo'
        end
      end
    end

    describe '#render' do
      before do
        @tmpdir = Dir.mktmpdir
        @original_dir = Dir.pwd
        Dir.chdir(@tmpdir)
        @renderer = make_renderer(
          content_hashes: Aardi::ContentHashes.new(File.join(@tmpdir, 'hashes.txt'))
        )
      end

      after do
        Dir.chdir(@original_dir)
        FileUtils.rm_rf(@tmpdir)
      end

      it 'writes index.json at the target path' do
        capture_io { make_feed([StubPost.new(Time.now)]).render(@renderer) }

        _(File.exist?(File.join(@tmpdir, 'index.json'))).must_equal true
      end

      it 'written file parses as a JSON Feed v1.1 document' do
        capture_io { make_feed([StubPost.new(Time.now)]).render(@renderer) }
        parsed = JSON.parse(File.read(File.join(@tmpdir, 'index.json')))

        _(parsed['version']).must_equal 'https://jsonfeed.org/version/1.1'
      end
    end
  end
end
