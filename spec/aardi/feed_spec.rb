# frozen_string_literal: true

require 'spec_helper'

class TestFeed < Aardi::Feed
  def content = '{}'

  private

  def feed_file = 'index.test'
end

class FeedSpec < Minitest::Spec
  describe Aardi::Feed do
    before do
      setup_config
    end

    it 'includes Renderable' do
      _(Aardi::Feed.include?(Aardi::Renderable)).must_equal true
    end

    it 'has Object as its superclass' do
      _(Aardi::Feed.superclass).must_equal Object
    end

    [Aardi::ATOMFeed, Aardi::JSONFeed].each do |klass|
      it "is the superclass of #{klass}" do
        _(klass.superclass).must_equal Aardi::Feed
      end
    end

    describe '#target_path' do
      it 'is ./<feed_file> without an archive path' do
        _(TestFeed.new([]).target_path).must_equal './index.test'
      end

      it 'is ./<archive_path>/<feed_file> with an archive path' do
        _(TestFeed.new([], 'tags/ruby').target_path).must_equal './tags/ruby/index.test'
      end
    end

    describe '#title' do
      it 'is private' do
        _(TestFeed.private_method_defined?(:title)).must_equal true
      end
    end
  end
end
