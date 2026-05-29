# frozen_string_literal: true

require 'spec_helper'
require 'aardi/post_record'
require 'aardi/meta_weblog_post_mapper'

class MetaWeblogPostMapperSpec < Minitest::Spec
  describe Aardi::MetaWeblogPostMapper do
    subject { Aardi::MetaWeblogPostMapper.new }

    describe '#fields' do
      it 'maps the struct to title, body and tags' do
        fields = subject.fields('title' => 'T', 'description' => "b\n", 'categories' => %w[ruby])

        _(fields).must_equal(title: 'T', body: "b\n", tags: %w[ruby])
      end

      it 'coerces a missing title and description to empty strings' do
        fields = subject.fields({})

        _(fields[:title]).must_equal ''
        _(fields[:body]).must_equal ''
      end
    end

    describe '#new_fields' do
      it 'adds the creation time parsed from dateCreated' do
        time = Time.utc(2024, 1, 5, 9, 0, 0)
        fields = subject.new_fields('title' => 'T', 'description' => 'b', 'dateCreated' => time)

        _(fields[:creation]).must_equal time
      end

      it 'defaults creation to now when dateCreated is absent' do
        _(subject.new_fields('title' => 'T').fetch(:creation)).must_be_kind_of Time
      end
    end

    describe '#media' do
      it 'maps name and bits onto MediaStore keywords' do
        _(subject.media('name' => 'pic.png', 'bits' => 'RAW')).must_equal(name: 'pic.png', bytes: 'RAW')
      end
    end

    describe '#to_struct' do
      it 'shapes a PostRecord into a MetaWeblog post struct' do
        record = Aardi::PostRecord.new(postid: 'a/1.md', title: 'Hi', body: "Body\n",
                                       creation: Time.utc(2024, 1, 5), updated: nil,
                                       tags: %w[ruby web], url: 'http://example.com/p/')
        struct = subject.to_struct(record)

        _(struct['postid']).must_equal 'a/1.md'
        _(struct['description']).must_equal "Body\n"
        _(struct['link']).must_equal 'http://example.com/p/'
        _(struct['permaLink']).must_equal 'http://example.com/p/'
        _(struct['categories']).must_equal %w[ruby web]
        _(struct['mt_keywords']).must_equal 'ruby, web'
      end
    end

    describe '#to_structs' do
      it 'maps a collection of records into structs' do
        record = Aardi::PostRecord.new(postid: 'p', title: 't', body: 'b', creation: Time.now,
                                       updated: nil, tags: [], url: 'u')

        _(subject.to_structs([record]).length).must_equal 1
      end
    end
  end
end
