# frozen_string_literal: true

require 'spec_helper'

class PostBookmarkLineSpec < Minitest::Spec
  describe Aardi::PostBookmarkLine do
    before do
      setup_config
    end

    def make_bookmark(url: 'http://example.com/blog/2024/01/05/my-post', tags: nil)
      post = Struct.new(:url, :tags).new(url, tags)
      Aardi::PostBookmarkLine.new(post)
    end

    describe '#to_s' do
      it 'includes a bookmark anchor pointing to the post URL' do
        bookmark = make_bookmark(url: 'http://example.com/blog/2024/01/05/my-post')

        _(bookmark.to_s).must_include '<a href="http://example.com/blog/2024/01/05/my-post">bookmark</a>'
      end

      it 'wraps everything in a span with class bookmark' do
        bookmark = make_bookmark

        _(bookmark.to_s).must_match(%r{<span class="bookmark">.*</span>}m)
      end

      it 'omits tag links when the post has no tags' do
        bookmark = make_bookmark(tags: nil)

        _(bookmark.to_s).wont_include '/tags/'
      end

      it 'renders tags in the order they are provided' do
        bookmark = make_bookmark(tags: %w[rails ruby])

        html = bookmark.to_s
        _(html).must_include '<a href="http://example.com/blog/tags/rails/">rails</a>'
        _(html).must_include '<a href="http://example.com/blog/tags/ruby/">ruby</a>'
        _(html.index('rails')).must_be :<, html.index('ruby')
      end

      it 'separates tag anchors with a comma and space' do
        bookmark = make_bookmark(tags: %w[rails ruby])

        _(bookmark.to_s).must_include 'rails</a>, <a href'
      end

      it 'omits tag links when blog_tags_path is not configured' do
        setup_config(blog_tags_path: nil)
        post = Struct.new(:url, :tags).new('http://example.com/post', %w[ruby])
        bookmark = Aardi::PostBookmarkLine.new(post)

        _(bookmark.to_s).wont_include '/tags/'
      end
    end
  end
end
