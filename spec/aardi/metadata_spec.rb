# frozen_string_literal: true

require 'spec_helper'

class MetadataSpec < Minitest::Spec
  describe Aardi::Metadata do
    describe '.parse' do
      it 'wraps a YAML hash in a Metadata' do
        _(Aardi::Metadata.parse("Title: Hello\n").title).must_equal 'Hello'
      end

      it 'returns an empty Metadata when input is empty' do
        _(Aardi::Metadata.parse('').empty?).must_equal true
      end

      it 'permits Time values for date fields' do
        meta = Aardi::Metadata.parse("Creation: 2024-01-05T00:00:00Z\n")

        _(meta.creation).must_be_kind_of Time
      end

      it 'warns on unknown declarations and ignores them' do
        _, err = capture_io do
          parsed = Aardi::Metadata.parse("Title: Hello\nWidget: foo\n")
          _(parsed.title).must_equal 'Hello'
        end

        _(err).must_match(/Widget/)
        _(err).must_match(/unknown/i)
      end

      it 'includes the source path in the warning when given' do
        _, err = capture_io do
          Aardi::Metadata.parse("Widget: foo\n", source: 'pages/x.md')
        end

        _(err).must_include 'pages/x.md'
      end
    end

    describe 'accessors' do
      it 'exposes title, description, creation, updated' do
        created_at = Time.utc(2024, 1, 5)
        updated_at = Time.utc(2024, 2, 1)
        meta = Aardi::Metadata.new({ 'Title' => 'T', 'Description' => 'D',
                                     'Creation' => created_at, 'Updated' => updated_at })

        _(meta.title).must_equal 'T'
        _(meta.description).must_equal 'D'
        _(meta.creation).must_equal created_at
        _(meta.updated).must_equal updated_at
      end

      it 'returns nil for missing fields' do
        empty = Aardi::Metadata.new({})

        _(empty.title).must_be_nil
        _(empty.description).must_be_nil
        _(empty.creation).must_be_nil
        _(empty.updated).must_be_nil
        _(empty.tags).must_be_nil
      end
    end

    describe '#tags' do
      it 'splits whitespace-separated tags and returns them sorted' do
        _(Aardi::Metadata.new({ 'Tags' => 'foo bar baz' }).tags).must_equal %w[bar baz foo]
      end

      it 'returns nil when Tags is not set' do
        _(Aardi::Metadata.new({}).tags).must_be_nil
      end
    end

    describe '#empty?' do
      it 'is true for an empty hash and false otherwise' do
        _(Aardi::Metadata.new({}).empty?).must_equal true
        _(Aardi::Metadata.new({ 'Title' => 'T' }).empty?).must_equal false
      end
    end

    describe 'unknown-key validation' do
      it 'warns and ignores unknown keys when constructed directly' do
        _, err = capture_io do
          meta = Aardi::Metadata.new({ 'Title' => 'T', 'Mystery' => 1 })
          _(meta.title).must_equal 'T'
        end

        _(err).must_match(/Mystery/)
      end
    end
  end
end
