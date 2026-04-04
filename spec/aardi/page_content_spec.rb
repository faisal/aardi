# frozen_string_literal: true

require "spec_helper"

class PageContentSpec < Minitest::Spec
  describe Aardi::PageContent do
    before do
      setup_config
      setup_ledger
    end

    subject { Aardi::PageContent.new("## Hello\n\nContent.", "My Title", {"Description" => "desc"}) }

    it "stores the title" do
      expect(subject.title).must_equal "My Title"
    end

    it "stores the metadata" do
      expect(subject.metadata["Description"]).must_equal "desc"
    end

    it "content returns the raw (stripped) source content" do
      expect(subject.content).must_equal "## Hello\n\nContent."
    end

    it "output returns HTML rendered via the template" do
      html = subject.output
      expect(html).must_include "<html"
      expect(html).must_include "My Title"
    end

    it "output is memoized" do
      expect(subject.output).must_be_same_as subject.output
    end

    it "output_hash is the CRC32 of output" do
      expect(subject.output_hash).must_equal Zlib.crc32(subject.output)
    end
  end
end
