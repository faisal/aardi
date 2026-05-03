# frozen_string_literal: true

require 'spec_helper'

class TagBlogSpec < Minitest::Spec
  describe Aardi::TagBlog do
    before do
      @config = setup_config
      @ledger = Aardi::Ledger.new
    end

    def make_tag_blog(posts, tag)
      tag_blog = Aardi::TagBlog.new(tag, config: @config, ledger: @ledger)
      posts.each do |post|
        tag_blog << post
      end
      tag_blog
    end

    describe '#initialize' do
      it 'sets archive_path under the tag sub-path' do
        archive = make_tag_blog([], 'news').send(:children).first

        _(archive.target_path).must_equal './blog/tags/news/blog/index.html'
      end
    end

    describe '#children' do
      it 'returns Archive, Home, ATOMFeed, and JSONFeed only' do
        children = make_tag_blog([], 'ruby').send(:children)

        _(children.map(&:class)).must_equal [
          Aardi::Archive, Aardi::Home, Aardi::ATOMFeed, Aardi::JSONFeed
        ]
      end

      it 'does not include a TagIndex' do
        tagged_post = StubPost.new(Time.utc(2024, 1, 1))
        tagged_post.define_singleton_method(:tags) { ['ruby'] }
        children = make_tag_blog([tagged_post], 'ruby').send(:children)

        _(children.map(&:class)).wont_include Aardi::TagIndex
      end
    end
  end
end
