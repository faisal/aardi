# frozen_string_literal: true

require "spec_helper"

# Use Page / Post as concrete hosts for AbstractPageSupport
class AbstractPageSupportSpec < Minitest::Spec
  describe Aardi::AbstractPageSupport do
    describe "#parse_source" do
      it "splits YAML frontmatter from content on the ---- separator" do
        page = Aardi::Page.new(sample_path("page_with_title.md"))
        expect(page.metadata["Title"]).must_equal "My Page"
        expect(page.content).must_include "# Heading"
        expect(page.content).must_include "Body text."
      end

      it "treats the entire file as content when there is no separator" do
        page = Aardi::Page.new(sample_path("page_no_frontmatter.md"))
        expect(page.metadata).must_equal({})
        expect(page.content).must_include "# Just Content"
      end

      it "parses Time values in frontmatter when permitted" do
        post = Aardi::Post.new(sample_path("post_with_creation.md"))
        expect(post.metadata["Creation"]).must_be_kind_of Time
      end

      it "records the file mtime" do
        page = Aardi::Page.new(sample_path("page_with_title.md"))
        expect(page.mtime).must_be_kind_of Time
      end
    end

    describe "#title" do
      it "returns the metadata Title when present" do
        page = Aardi::Page.new(sample_path("page_explicit_title.md"))
        expect(page.title).must_equal "Explicit Title"
      end

      it "extracts title from the first markdown heading when no metadata Title" do
        page = Aardi::Page.new(sample_path("page_heading_title.md"))
        expect(page.title).must_equal "My Heading"
      end
    end
  end
end
