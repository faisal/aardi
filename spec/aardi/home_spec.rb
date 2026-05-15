# frozen_string_literal: true

require 'spec_helper'

class HomeSpec < Minitest::Spec
  describe Aardi::Home do
    before do
      setup_config
    end

    def make_home(posts)
      Aardi::Home.new(posts, 'blog')
    end

    describe '#title' do
      it 'returns blog_home_title from config' do
        _(make_home([]).title).must_equal 'Test Site'
      end
    end

    describe '#target_path' do
      it 'is ./index.html' do
        _(make_home([]).target_path).must_equal './index.html'
      end

      it 'is ./blog-path/index.html when blog_path is set' do
        home = Aardi::Home.new([], 'blog', 'tags/foo')

        _(home.target_path).must_equal './tags/foo/index.html'
      end
    end

    describe '#content' do
      it 'includes the site title heading' do
        content = make_home([]).content

        _(content).must_include '# Test Site'
      end

      it 'includes footer links to Archive, RSS, and JSON' do
        content = make_home([]).content

        _(content).must_include 'Archive'
        _(content).must_include 'RSS'
        _(content).must_include 'JSON'
      end

      it 'groups posts by day with a day heading' do
        posts = [StubPost.new(Time.now, title: 'Morning'), StubPost.new(Time.now, title: 'Evening')]
        content = make_home(posts).content

        _(content).must_include '## '
        _(content).must_include 'Morning'
        _(content).must_include 'Evening'
      end

      it 'includes posts from different days separately' do
        jan_ten = StubPost.new(Time.utc(2024, 1, 10), title: 'Jan 10 Post')
        jan_fifteen = StubPost.new(Time.utc(2024, 1, 15), title: 'Jan 15 Post')
        content = make_home([jan_ten, jan_fifteen]).content

        _(content).must_include 'Jan 10 Post'
        _(content).must_include 'Jan 15 Post'
        _(content.scan(/^## /).length).must_equal 2
      end

      it 'includes the archive URL in the footer' do
        content = make_home([]).content

        _(content).must_include 'http://example.com/blog/'
      end

      describe 'with blog_path' do
        def make_home_with_blog_path
          Aardi::Home.new([StubPost.new(Time.now)], 'blog', 'tags/foo')
        end

        it 'uses blog_path for feed URLs in footer' do
          content = make_home_with_blog_path.content

          _(content).must_include 'http://example.com/tags/foo/index.xml'
          _(content).must_include 'http://example.com/tags/foo/index.json'
        end
      end
    end

    describe '#children (private)' do
      it 'returns the posts the home was constructed with' do
        posts = [StubPost.new(Time.now)]

        _(Aardi::Home.new(posts, 'blog').send(:children)).must_equal posts
      end
    end

    describe '#render' do
      before do
        setup_ledger
        @tmpdir = Dir.mktmpdir
        @original_dir = Dir.pwd
        Dir.chdir(@tmpdir)
        Aardi.ledger[:html_files] = Set.new
        Aardi.ledger[:content_hashes] = Aardi::ContentHashes.new(File.join(@tmpdir, 'hashes.txt'))
        Aardi.ledger[:sitemap] = Aardi::Sitemap.new
      end

      after do
        Dir.chdir(@original_dir)
        FileUtils.rm_rf(@tmpdir)
      end

      it 'writes ./index.html when no blog_path is given' do
        home = Aardi::Home.new([StubPost.new(Time.now)], 'blog')

        capture_io { home.render }

        _(File.exist?(File.join(@tmpdir, 'index.html'))).must_equal true
      end

      it "updates the sitemap mtime for '/' when no blog_path is given" do
        home = Aardi::Home.new([StubPost.new(Time.now)], 'blog')

        capture_io { home.render }

        _(Aardi.ledger[:sitemap].urls['/'][:lastmod]).wont_be_nil
      end

      it 'writes the target page when blog_path is given' do
        home = Aardi::Home.new([StubPost.new(Time.now)], 'blog', 'tags/foo')

        capture_io { home.render }

        _(File.exist?(File.join(@tmpdir, 'tags', 'foo', 'index.html'))).must_equal true
      end

      it 'does not update the sitemap when blog_path is given' do
        home = Aardi::Home.new([StubPost.new(Time.now)], 'blog', 'tags/foo')

        capture_io { home.render }

        _(Aardi.ledger[:sitemap].urls['/'].key?(:lastmod)).must_equal false
      end
    end
  end
end
