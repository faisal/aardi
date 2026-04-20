# frozen_string_literal: true

require 'spec_helper'

class ContentSpec < Minitest::Spec
  describe Aardi::Content do
    describe '#output' do
      it 'strips leading and trailing whitespace from source content' do
        content = Aardi::Content.new('  hello  ')

        _(content.output).must_equal 'hello'
      end

      it 'returns the stripped content unchanged' do
        content = Aardi::Content.new('plain text')

        _(content.output).must_equal 'plain text'
      end

      it 'is memoized' do
        content = Aardi::Content.new('text')

        _(content.output).must_be_same_as content.output
      end
    end

    describe '#output_hash' do
      it 'returns the CRC32 checksum of output' do
        content = Aardi::Content.new('hello')

        _(content.output_hash).must_equal Zlib.crc32('hello')
      end

      it 'differs for different content' do
        hello = Aardi::Content.new('hello')
        world = Aardi::Content.new('world')

        _(hello.output_hash).wont_equal world.output_hash
      end
    end
  end
end
