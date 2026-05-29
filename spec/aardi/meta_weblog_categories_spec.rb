# frozen_string_literal: true

require 'spec_helper'
require 'aardi/post_record'
require 'aardi/meta_weblog_categories'

class MetaWeblogCategoriesSpec < Minitest::Spec
  describe Aardi::MetaWeblogCategories do
    subject { Aardi::MetaWeblogCategories.new }

    def record(tags)
      Aardi::PostRecord.new(postid: 'p', title: 't', body: 'b', creation: Time.now,
                            updated: nil, tags:, url: 'u')
    end

    describe '#from_struct' do
      it 'uses the categories array when present' do
        _(subject.from_struct('categories' => %w[ruby web])).must_equal %w[ruby web]
      end

      it 'falls back to comma-separated mt_keywords' do
        _(subject.from_struct('mt_keywords' => 'alpha, beta')).must_equal %w[alpha beta]
      end

      it 'returns an empty array when neither is given' do
        _(subject.from_struct({})).must_equal []
      end
    end

    describe '#assigned' do
      it 'wraps tags as non-primary category structs' do
        _(subject.assigned(%w[a])).must_equal [{ 'categoryName' => 'a', 'isPrimary' => false }]
      end
    end

    describe '#names' do
      it 'reads names from hash categories and passes strings through' do
        cats = [{ 'categoryName' => 'x' }, { 'categoryId' => 'y' }, 'z']

        _(subject.names(cats)).must_equal %w[x y z]
      end
    end

    describe '#list' do
      before { setup_config(blog_tags_path: 'tags') }

      it 'builds a sorted, de-duplicated category struct per distinct tag' do
        names = subject.list([record(%w[ruby]), record(%w[web ruby])]).map { |cat| cat['categoryName'] }

        _(names).must_equal %w[ruby web]
      end

      it 'links each category to its tag page' do
        cat = subject.list([record(%w[ruby])]).first

        _(cat['htmlUrl']).must_equal 'http://example.com/tags/ruby/'
      end
    end
  end
end
