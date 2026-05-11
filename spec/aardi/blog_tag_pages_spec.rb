# frozen_string_literal: true

require 'spec_helper'

class BlogTagPagesSpec < Minitest::Spec
  describe Aardi::BlogTagPages do
    before do
      setup_config
      setup_ledger
      @proxy = Aardi::BlogTagPages.new
    end

    def tagged_post(tags)
      StubPost.new(Time.utc(2024, 1, 1), tags:)
    end

    describe '#empty?' do
      it 'is true with no posts' do
        _(@proxy.empty?).must_equal true
      end

      it 'is false once a tagged post is added' do
        @proxy << tagged_post(%w[foo])

        _(@proxy.empty?).must_equal false
      end

      it 'remains true when an untagged post is added' do
        @proxy << tagged_post([])

        _(@proxy.empty?).must_equal true
      end
    end

    describe '#archive_tag_index' do
      it 'is non-nil once a tagged post is added' do
        @proxy << tagged_post(%w[foo])

        _(@proxy.archive_tag_index).wont_be_nil
      end

      it 'returns a TagIndex whose content has correct per-tag counts' do
        @proxy << tagged_post(%w[foo])
        @proxy << tagged_post(%w[foo])
        @proxy << tagged_post(%w[bar])

        content = @proxy.archive_tag_index.content
        _(content).must_match(/\[foo\]\([^)]+\) \(2\)/)
        _(content).must_match(/\[bar\]\([^)]+\) \(1\)/)
      end

      it 'reflects posts added after the index is first observed' do
        index = @proxy.archive_tag_index
        @proxy << tagged_post(%w[foo])

        _(index.content).must_include '[foo]'
      end
    end

    describe '#children' do
      it 'is empty before any tagged post is added' do
        _(@proxy.children).must_equal []
      end

      it 'contains a TagIndex and a TagBlog per tag once tagged posts are added' do
        @proxy << tagged_post(%w[foo bar])

        classes = @proxy.children.map(&:class)
        _(classes).must_include Aardi::TagIndex
        _(classes.count { |class_count| class_count == Aardi::TagBlog }).must_equal 2
      end
    end

    describe '#<<' do
      it 'distributes a post to each of its tag blogs' do
        post = tagged_post(%w[foo bar])
        @proxy << post

        @proxy.children.grep(Aardi::TagBlog).each do |tag_blog|
          _(tag_blog.instance_variable_get(:@posts)).must_include post
        end
      end

      it 'ignores posts with no tags' do
        @proxy << tagged_post([])

        _(@proxy.children).must_equal []
      end
    end
  end
end
