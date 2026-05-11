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
        home = Aardi::Home.new([], 'blog', blog_path: 'blog/tags/foo')

        _(home.target_path).must_equal './blog/tags/foo/index.html'
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
          Aardi::Home.new([StubPost.new(Time.now)], 'blog', blog_path: 'blog/tags/foo')
        end

        it 'uses blog_path for feed URLs in footer' do
          content = make_home_with_blog_path.content

          _(content).must_include 'http://example.com/blog/tags/foo/index.xml'
          _(content).must_include 'http://example.com/blog/tags/foo/index.json'
        end
      end
    end
  end
end
