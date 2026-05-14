# frozen_string_literal: true

require 'spec_helper'

class MetadataSpec < Minitest::Spec
  describe Aardi::Metadata do
    describe '.new' do
      it 'wraps a YAML hash in a Metadata' do
        _(Aardi::Metadata.new("Title: Hello\n").title).must_equal 'Hello'
      end

      it 'returns an empty Metadata when input is empty' do
        _(Aardi::Metadata.new('').empty?).must_equal true
      end

      it 'returns an empty Metadata when called with no arguments' do
        _(Aardi::Metadata.new.empty?).must_equal true
      end

      it 'permits Time values for date fields' do
        meta = Aardi::Metadata.new("Creation: 2024-01-05T00:00:00Z\n")

        _(meta.creation).must_be_kind_of Time
      end

      it 'warns on unknown declarations and ignores them' do
        _, err = capture_io do
          parsed = Aardi::Metadata.new("Title: Hello\nWidget: foo\n")
          _(parsed.title).must_equal 'Hello'
        end

        _(err).must_match(/Widget/)
        _(err).must_match(/unknown/i)
      end

      it 'includes the source path in the warning when given' do
        _, err = capture_io do
          Aardi::Metadata.new("Widget: foo\n", source: 'pages/x.md')
        end

        _(err).must_include 'pages/x.md'
      end
    end

    describe 'accessors' do
      it 'exposes title, description, creation, updated' do
        yaml = "Title: T\nDescription: D\nCreation: 2024-01-05T00:00:00Z\nUpdated: 2024-02-01T00:00:00Z\n"
        meta = Aardi::Metadata.new(yaml)

        _(meta.title).must_equal 'T'
        _(meta.description).must_equal 'D'
        _(meta.creation).must_be_kind_of Time
        _(meta.updated).must_be_kind_of Time
      end

      it 'returns nil for missing fields' do
        empty = Aardi::Metadata.new

        _(empty.title).must_be_nil
        _(empty.description).must_be_nil
        _(empty.creation).must_be_nil
        _(empty.updated).must_be_nil
        _(empty.tags).must_be_nil
      end
    end

    describe '#tags' do
      it 'splits whitespace-separated tags and returns them sorted' do
        _(Aardi::Metadata.new("Tags: foo bar baz\n").tags).must_equal %w[bar baz foo]
      end

      it 'returns nil when Tags is not set' do
        _(Aardi::Metadata.new.tags).must_be_nil
      end
    end

    describe '#empty?' do
      it 'is true for empty input and false otherwise' do
        _(Aardi::Metadata.new.empty?).must_equal true
        _(Aardi::Metadata.new("Title: T\n").empty?).must_equal false
      end
    end

    describe 'unknown-key validation' do
      it 'warns and ignores unknown keys' do
        _, err = capture_io do
          meta = Aardi::Metadata.new("Title: T\nMystery: 1\n")
          _(meta.title).must_equal 'T'
        end

        _(err).must_match(/Mystery/)
      end
    end
  end
end
