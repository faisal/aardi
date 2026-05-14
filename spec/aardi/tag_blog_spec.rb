# frozen_string_literal: true

require 'spec_helper'

class TagBlogSpec < Minitest::Spec
  describe Aardi::TagBlog do
    before do
      setup_config
    end

    def make_tag_blog(posts, tag)
      tag_blog = Aardi::TagBlog.new(tag)
      posts.each do |post|
        tag_blog << post
      end
      tag_blog
    end

    describe '#initialize' do
      it 'sets archive_path under the tag sub-path' do
        archive = make_tag_blog([], 'news').send(:children).first

        _(archive.target_path).must_equal './tags/news/blog/index.html'
      end
    end

    describe '#inline_link_text' do
      it 'returns a markdown link with the post count in parentheses' do
        tag_blog = make_tag_blog([StubPost.new(Time.utc(2024, 1, 1)),
                                  StubPost.new(Time.utc(2024, 2, 1))], 'news')

        _(tag_blog.inline_link_text).must_equal '[news](http://example.com/tags/news/) (2)'
      end
    end

    describe '#children' do
      it 'returns Archive, Home, ATOMFeed, and JSONFeed only' do
        children = make_tag_blog([], 'foo').send(:children)

        _(children.map(&:class)).must_equal [
          Aardi::Archive, Aardi::Home, Aardi::ATOMFeed, Aardi::JSONFeed
        ]
      end

      it 'does not include a Tags' do
        tagged_post = StubPost.new(Time.utc(2024, 1, 1))
        tagged_post.define_singleton_method(:tags) { ['foo'] }
        children = make_tag_blog([tagged_post], 'foo').send(:children)

        _(children.map(&:class)).wont_include Aardi::Tags
      end
    end
  end
end
