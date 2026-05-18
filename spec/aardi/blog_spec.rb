# frozen_string_literal: true

require 'spec_helper'

class BlogSpec < Minitest::Spec
  describe Aardi::Blog do
    before do
      setup_config
    end

    def make_blog(posts)
      blog = Aardi::Blog.new
      posts.each do |post|
        blog << post
      end
      blog
    end

    def posts_across_years
      [
        StubPost.new(Time.utc(2022, 1, 1), name: 'oldest', title: 'Oldest', tags: []),
        StubPost.new(Time.utc(2023, 1, 1), name: 'middle', title: 'Middle', tags: %w[one]),
        StubPost.new(Time.utc(2024, 1, 1), name: 'newest', title: 'Newest', tags: %w[one two])
      ]
    end

    describe '#initialize' do
      it 'defaults archive_path to config[:blog_archive_path]' do
        archive = make_blog([]).send(:children).first

        _(archive.target_path).must_equal './blog/index.html'
      end
    end

    describe '#children' do
      it 'returns an Archive, Home, ATOMFeed, JSONFeed, and Tags objects in that order' do
        children = make_blog([]).send(:children)

        _(children.map(&:class)).must_equal [
          Aardi::Archive, Aardi::Home, Aardi::ATOMFeed, Aardi::JSONFeed, Aardi::Tags
        ]
      end

      it 'returns all five children even when there are no posts' do
        _(make_blog([]).send(:children).length).must_equal 5
      end

      it 'includes a Tags when the root blog has tagged posts' do
        tagged_post = StubPost.new(Time.utc(2024, 1, 1))
        tagged_post.define_singleton_method(:tags) { ['foo'] }
        children = make_blog([tagged_post]).send(:children)

        _(children.map(&:class)).must_include Aardi::Tags
      end

      it 'Tags child contains a TagBlog for each tag' do
        tagged_post = StubPost.new(Time.utc(2024, 1, 1))
        tagged_post.define_singleton_method(:tags) { ['foo'] }
        tags_child = make_blog([tagged_post]).send(:children).grep(Aardi::Tags).first

        _(tags_child.send(:children).map(&:class)).must_include Aardi::TagBlog
      end

      it 'archive content lists tag links once tagged posts are added' do
        tagged_post = StubPost.new(Time.utc(2024, 1, 1))
        tagged_post.define_singleton_method(:tags) { ['foo'] }
        archive = make_blog([tagged_post]).send(:children).first

        _(archive.content).must_include '**What**:'
        _(archive.content).must_include '[foo]'
      end
    end

    describe '#recent_posts' do
      it 'returns the last N posts reversed so newest is first' do
        setup_config(blog_home_posts: 2)
        blog = make_blog(posts_across_years)

        selection = blog.send(:recent_posts, :blog_home_posts)

        _(selection.map(&:name)).must_equal %w[newest middle]
      end

      it 'uses the config key it was passed, so feed and home counts differ' do
        setup_config(blog_feed_posts: 1, blog_home_posts: 3)
        blog = make_blog(posts_across_years)

        _(blog.send(:recent_posts, :blog_feed_posts).map(&:name)).must_equal ['newest']
        _(blog.send(:recent_posts, :blog_home_posts).map(&:name))
          .must_equal %w[newest middle oldest]
      end

      it 'returns all posts reversed when there are fewer posts than the limit' do
        setup_config(blog_home_posts: 10)
        blog = make_blog(posts_across_years)

        _(blog.send(:recent_posts, :blog_home_posts).map(&:name))
          .must_equal %w[newest middle oldest]
      end

      it 'returns an empty list when there are no posts' do
        _(make_blog([]).send(:recent_posts, :blog_home_posts)).must_equal []
      end
    end

    describe '#report_recent' do
      it 'calls report_field_summary on the last blog_recent_posts, newest first' do
        setup_config(blog_recent_posts: 2)
        reported = []
        posts = posts_across_years.each do |post|
          post.define_singleton_method(:report_field_summary) { reported << name }
        end

        make_blog(posts).report_recent

        _(reported).must_equal %w[newest middle]
      end

      it 'reports on all posts when there are fewer than blog_recent_posts' do
        setup_config(blog_recent_posts: 10)
        reported = []
        posts = posts_across_years.each do |post|
          post.define_singleton_method(:report_field_summary) { reported << name }
        end

        make_blog(posts).report_recent

        _(reported).must_equal %w[newest middle oldest]
      end

      it 'is a no-op when there are no posts' do
        make_blog([]).report_recent
      end
    end

    describe '#write_target' do
      it 'returns {} so rendering Blog writes no file of its own' do
        _(make_blog([]).send(:write_target, nil)).must_equal({})
      end
    end
  end
end
