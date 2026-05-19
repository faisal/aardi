# frozen_string_literal: true

require 'spec_helper'

class PageContentSpec < Minitest::Spec
  describe Aardi::PageContent do
    before do
      setup_config
      make_renderer
    end

    subject do
      Aardi::PageContent.new("## Hello\n\nContent.", 'My Title', Aardi::Metadata.new("Description: desc\n"))
    end

    it 'stores the title' do
      _(subject.title).must_equal 'My Title'
    end

    it 'stores the metadata' do
      _(subject.metadata.description).must_equal 'desc'
    end

    it 'content returns the raw (stripped) source content' do
      _(subject.content).must_equal "## Hello\n\nContent."
    end

    it 'output returns HTML rendered via the renderer' do
      html = subject.output
      _(html).must_include '<html'
      _(html).must_include 'My Title'
    end

    it 'output is memoized' do
      _(subject.output).must_be_same_as subject.output
    end

    it 'output_hash is the CRC32 of output' do
      _(subject.output_hash).must_equal Zlib.crc32(subject.output)
    end
  end
end
