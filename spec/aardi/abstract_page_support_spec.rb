# frozen_string_literal: true

require 'spec_helper'

class AbstractPageSupportSpec < Minitest::Spec
  describe Aardi::AbstractPageSupport do
    describe '#parse_source' do
      it 'splits out YAML frontmatter and content at the ---- separator' do
        page = page_by_sample_path 'page_with_title.md'

        _(page.metadata).wont_be_empty
        _(page.content).wont_be_empty
      end

      it 'treats the entire file as content when there is no separator' do
        page = page_by_sample_path 'page_no_frontmatter.md'

        _(page.metadata).must_be_empty
        _(page.content).wont_be_empty
      end

      it 'parses Time values in frontmatter when permitted' do
        page = page_by_sample_path 'post_with_creation.md'

        _(page.metadata.creation).must_be_kind_of Time
      end

      it 'records the file mtime' do
        page_path = sample_path 'page_with_title.md'
        page = page_by_sample_path 'page_with_title.md'

        _(page.mtime).must_equal File.mtime(page_path).utc
      end
    end

    describe 'title' do
      it 'extracts title from the first markup heading when no metadata Title' do
        page = page_by_sample_path 'page_heading_title.md'

        _(page.title).must_equal 'My Heading'
      end

      it 'returns the metadata Title when present' do
        page = page_by_sample_path 'page_explicit_title.md'

        _(page.title).must_equal 'Explicit Title'
      end
    end
  end
end
