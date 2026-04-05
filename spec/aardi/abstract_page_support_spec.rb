# frozen_string_literal: true

require "spec_helper"

# Use Page / Post as concrete hosts for AbstractPageSupport
class AbstractPageSupportSpec < Minitest::Spec
  describe Aardi::AbstractPageSupport do
    describe "#parse_source" do
      it "splits out YAML frontmatter and content at the ---- separator" do
        page = page_by_sample_path "page_with_title.md"

        expect(page.metadata).wont_be_empty
        expect(page.content).wont_be_empty
      end

      it "treats the entire file as content when there is no separator" do
        page = page_by_sample_path "page_no_frontmatter.md"

        expect(page.metadata).must_be_empty
        expect(page.content).wont_be_empty
      end

      it "parses Time values in frontmatter when permitted" do
        page = page_by_sample_path "post_with_creation.md"

        expect(page.metadata["Creation"]).must_be_kind_of Time
      end

      it "records the file mtime" do
        page_path = sample_path "page_with_title.md"
        page = page_by_sample_path "page_with_title.md"

        expect(page.mtime).must_equal File.mtime(page_path).utc
      end

      it "extracts title from the first markdown heading when no metadata Title" do
        page = page_by_sample_path "page_heading_title.md"

        expect(page.title).must_equal "My Heading"
      end

      it "returns the metadata Title when present" do
        page = page_by_sample_path "page_explicit_title.md"

        expect(page.title).must_equal "Explicit Title"
      end
    end
  end
end
