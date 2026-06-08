# frozen_string_literal: true

require 'spec_helper'

class FeedMenuSpec < Minitest::Spec
  describe Aardi::FeedMenu do
    before do
      setup_config
    end

    def make_blog(*tag_lists)
      blog = Aardi::Blog.new
      tag_lists.each_with_index do |tags, idx|
        blog << StubPost.new(Time.utc(2024, 1, idx + 1), name: "post-#{idx}", tags:)
      end
      blog
    end

    def parsed(blog = Aardi::Blog.new)
      JSON.parse(Aardi::FeedMenu.new(blog).content)
    end

    describe '#target_path' do
      it 'is ./.well-known/feed-menu.json' do
        _(Aardi::FeedMenu.new(Aardi::Blog.new).target_path)
          .must_equal './.well-known/feed-menu.json'
      end
    end

    describe '#content' do
      it 'sets the top-level feed-menu to the site_title' do
        _(parsed['feed-menu']).must_equal 'Test Site'
      end

      it 'includes a site item as the first entry' do
        _(parsed['items'].first).must_equal(
          'feed-title' => 'Test Site',
          'rss' => '/index.xml',
          'json' => '/index.json'
        )
      end

      it 'has only the site item when there are no tag blogs' do
        _(parsed['items'].length).must_equal 1
      end

      it 'adds one item per tag blog beyond the site item' do
        _(parsed(make_blog(%w[news], %w[fun]))['items'].length).must_equal 3
      end

      it 'titles each tag item as "<site_title> - <tag>"' do
        titles = parsed(make_blog(%w[news], %w[fun]))['items'].drop(1).map { |item| item['feed-title'] }

        _(titles).must_include 'Test Site - news'
        _(titles).must_include 'Test Site - fun'
      end

      it 'points each tag item rss element at the tag atom feed path' do
        item = parsed(make_blog(%w[news]))['items'].drop(1).first

        _(item['rss']).must_equal '/tags/news/index.xml'
      end

      it 'points each tag item json element at the tag json feed path' do
        item = parsed(make_blog(%w[news]))['items'].drop(1).first

        _(item['json']).must_equal '/tags/news/index.json'
      end
    end

    describe '#render' do
      before do
        @tmpdir = Dir.mktmpdir
        @original_dir = Dir.pwd
        Dir.chdir(@tmpdir)
        make_renderer(
          content_hashes: Aardi::ContentHashes.new(File.join(@tmpdir, 'hashes.txt'))
        )
      end

      after do
        Dir.chdir(@original_dir)
        FileUtils.rm_rf(@tmpdir)
      end

      it 'writes .well-known/feed-menu.json at the target path' do
        capture_io { Aardi::FeedMenu.new(Aardi::Blog.new).render }

        _(File.exist?(File.join(@tmpdir, '.well-known', 'feed-menu.json'))).must_equal true
      end

      it 'written file parses as JSON with the site_title' do
        capture_io { Aardi::FeedMenu.new(Aardi::Blog.new).render }
        parsed = JSON.parse(File.read(File.join(@tmpdir, '.well-known', 'feed-menu.json')))

        _(parsed['feed-menu']).must_equal 'Test Site'
      end
    end
  end
end
