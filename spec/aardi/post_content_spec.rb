# frozen_string_literal: true

require 'spec_helper'
require 'aardi/post_content'
require 'aardi/post_record'

class PostContentSpec < Minitest::Spec
  describe Aardi::PostContent do
    describe '.fresh' do
      it 'builds content with no Updated timestamp' do
        content = Aardi::PostContent.fresh(title: 'T', body: "b\n", tags: %w[x],
                                           creation: Time.utc(2024, 1, 5))

        _(content.title).must_equal 'T'
        _(content.updated).must_be_nil
      end
    end

    describe '.editing' do
      it 'copies the record fields and stamps the given Updated time' do
        record = Aardi::PostRecord.new(postid: 'p', title: 'Old', body: "body\n",
                                       creation: Time.utc(2024, 1, 5), updated: nil,
                                       tags: %w[a b], url: 'http://example.com/p/')
        updated = Time.utc(2024, 2, 1)
        content = Aardi::PostContent.editing(record, updated:)

        _(content.title).must_equal 'Old'
        _(content.body).must_equal "body\n"
        _(content.tags).must_equal %w[a b]
        _(content.creation).must_equal Time.utc(2024, 1, 5)
        _(content.updated).must_equal updated
      end
    end
  end
end
