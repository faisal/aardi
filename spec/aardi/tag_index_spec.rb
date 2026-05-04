# frozen_string_literal: true

require 'spec_helper'

class TagIndexSpec < Minitest::Spec
  describe Aardi::TagIndex do
    before do
      @config = setup_config
      @ledger = Aardi::Ledger.new
    end

    def make_index(tag_counts)
      Aardi::TagIndex.new(tag_counts, config: @config, ledger: @ledger)
    end

    describe '#target_path' do
      it 'returns the tags index path using config values' do
        _(make_index({}).target_path).must_equal './blog/tags/index.html'
      end
    end

    describe '#title' do
      it 'returns "Tags"' do
        _(make_index({}).title).must_equal 'Tags'
      end
    end

    describe '#content' do
      it 'includes a markup link for each tag pointing to the correct URL' do
        index = make_index('ruby' => 1)

        _(index.content).must_include '[ruby](http://example.com/blog/tags/ruby/)'
      end

      it 'includes the post count in parentheses' do
        index = make_index('ruby' => 3)

        _(index.content).must_include '(3)'
      end

      it 'sorts tags alphabetically' do
        index = make_index('zebra' => 1, 'apple' => 2, 'mango' => 3)

        positions = %w[apple mango zebra].map { |tag| index.content.index(tag) }
        _(positions).must_equal positions.sort
      end

      it 'produces just the heading when tag_counts is empty' do
        _(make_index({}).content).must_equal "# Tags\n"
      end
    end
  end
end
