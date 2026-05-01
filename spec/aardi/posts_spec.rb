# frozen_string_literal: true

require 'spec_helper'

class PostsSpec < Minitest::Spec
  describe Aardi::Posts do
    before do
      @config = setup_config
      @ledger = Aardi::Ledger.new
    end

    def tagged(post, *tags)
      post.define_singleton_method(:tags) { tags }
      post
    end

    describe '#list' do
      it 'preserves the input order (does not sort)' do
        newer = StubPost.new(Time.utc(2024, 1, 1), name: 'newer')
        older = StubPost.new(Time.utc(2022, 1, 1), name: 'older')
        posts = make_posts([newer, older], config: @config, ledger: @ledger)

        _(posts.list.map(&:name)).must_equal %w[newer older]
      end
    end

    describe '#tag_groups' do
      it 'returns an empty hash when no posts have tags' do
        posts = make_posts([StubPost.new(Time.utc(2024, 1, 1))], config: @config, ledger: @ledger)

        _(posts.tag_groups).must_equal({})
      end

      it 'buckets posts by each tag' do
        post_a = tagged(StubPost.new(Time.utc(2024, 1, 1), name: 'a'), 'ruby', 'rails')
        post_b = tagged(StubPost.new(Time.utc(2024, 2, 1), name: 'b'), 'ruby')
        posts = make_posts([post_a, post_b], config: @config, ledger: @ledger)

        _(posts.tag_groups['ruby'].map(&:name)).must_equal %w[a b]
        _(posts.tag_groups['rails'].map(&:name)).must_equal %w[a]
      end

      it 'skips posts with no tags' do
        tagged_post = tagged(StubPost.new(Time.utc(2024, 1, 1), name: 'tagged'), 'ruby')
        untagged_post = StubPost.new(Time.utc(2024, 2, 1), name: 'untagged')
        posts = make_posts([tagged_post, untagged_post], config: @config, ledger: @ledger)

        _(posts.tag_groups.keys).must_equal ['ruby']
      end
    end

    describe '#calendar' do
      it 'returns a hash keyed by year integer' do
        post = StubPost.new(Time.utc(2024, 6, 1))
        posts = make_posts([post], config: @config, ledger: @ledger)

        _(posts.calendar.keys).must_equal [2024]
      end

      it 'maps each year to an Aardi::Year' do
        post = StubPost.new(Time.utc(2023, 3, 1))
        posts = make_posts([post], config: @config, ledger: @ledger)

        _(posts.calendar[2023]).must_be_instance_of Aardi::Year
      end

      it 'returns nil for an unknown year (no auto-vivification)' do
        posts = make_posts([], config: @config, ledger: @ledger)

        _(posts.calendar[9999]).must_be_nil
      end
    end

    describe '#list_for' do
      it 'returns the posts for a known tag' do
        post = tagged(StubPost.new(Time.utc(2024, 1, 1), name: 'tagged'), 'ruby')
        posts = make_posts([post], config: @config, ledger: @ledger)

        _(posts.list_for('ruby').map(&:name)).must_equal ['tagged']
      end

      it 'returns an empty array for an unknown tag' do
        posts = make_posts([], config: @config, ledger: @ledger)

        _(posts.list_for('nonexistent')).must_equal []
      end
    end

    describe '#calendar_for' do
      it 'returns the calendar for a known tag' do
        post = tagged(StubPost.new(Time.utc(2024, 5, 1)), 'ruby')
        posts = make_posts([post], config: @config, ledger: @ledger)

        _(posts.calendar_for('ruby')).must_be_kind_of Hash
        _(posts.calendar_for('ruby')[2024]).must_be_instance_of Aardi::Year
      end

      it 'returns nil for an unknown tag (no auto-vivification)' do
        posts = make_posts([], config: @config, ledger: @ledger)

        _(posts.calendar_for('nonexistent')).must_be_nil
      end
    end
  end
end
