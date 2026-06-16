# frozen_string_literal: true

require 'spec_helper'

class PostSpec < Minitest::Spec
  describe Aardi::Post do
    before do
      setup_config
      make_renderer
      @tmpdir = Dir.mktmpdir
    end

    after do
      FileUtils.rm_rf(@tmpdir)
    end

    # :reek:LongParameterList
    def make_post(creation: Time.now, title: 'My Post', name: 'my-post', extra_yaml: '')
      content = "Creation: #{creation.iso8601}\n#{extra_yaml}\n----\n### #{title}\n\nBody text.\n"
      path = File.join(@tmpdir, "#{name}.md")
      File.write(path, content)
      Aardi::Post.new(path)
    end

    describe '#creation' do
      it 'returns the Creation value from metadata as a Time' do
        post = make_post(creation: Time.utc(2024, 3, 10, 8, 0, 0))

        _(post.creation).must_be_kind_of Time
        _(post.creation.year).must_equal 2024
        _(post.creation.month).must_equal 3
        _(post.creation.day).must_equal 10
      end
    end

    describe '#name' do
      it 'returns the filename without extension' do
        post = make_post(name: 'cool-post')

        _(post.name).must_equal 'cool-post'
      end
    end

    describe '#url' do
      it 'builds the URL from site_url, archive_path, date, and name' do
        post = make_post(creation: Time.utc(2024, 1, 5, 0, 0, 0), name: 'my-post')

        _(post.url).must_equal 'http://example.com/blog/2024/01/05/my-post'
      end
    end

    describe '#target_path' do
      it 'uses the archive path and creation date' do
        post = make_post(creation: Time.utc(2024, 1, 5, 0, 0, 0), name: 'my-post')

        _(post.target_path).must_equal './blog/2024/01/05/my-post.html'
      end
    end

    describe '#updated' do
      it 'returns creation when no Updated metadata' do
        post = make_post(creation: Time.now)

        _(post.updated).must_equal post.creation
      end

      it 'returns the Updated metadata value when present' do
        post = make_post(creation: Time.now, extra_yaml: 'Updated: 2024-02-01T00:00:00Z')

        _(post.updated.year).must_equal 2024
        _(post.updated.month).must_equal 2
      end
    end

    describe '#content' do
      it 'includes the source content' do
        post = make_post(title: 'My Post')

        _(post.content).must_include 'Body text.'
      end

      it 'appends a bookmark link pointing to the post URL' do
        post = make_post(name: 'bookmarked-post', creation: Time.now)

        _(post.content).must_include 'class="bookmark"'
        _(post.content).must_include post.url
      end

      it 'renders tag links when tags are present' do
        post = make_post(extra_yaml: 'Tags: foo bar')
        bookmark_span = post.content[%r{<span class="bookmark">[^<]*(?:<[^>]+>[^<]*)*</span>}]

        _(bookmark_span).must_include '<a href="http://example.com/tags/foo/">foo</a>'
        _(bookmark_span).must_include '<a href="http://example.com/tags/bar/">bar</a>'
      end

      it 'renders tag links after the bookmark when tags are present' do
        post = make_post(extra_yaml: 'Tags: foo bar')
        bookmark_span = post.content[%r{<span class="bookmark">[^<]*(?:<[^>]+>[^<]*)*</span>}]

        _(bookmark_span.index('bar')).must_be :>, bookmark_span.index('bookmark</a>')
      end

      it 'renders tag links in alphabetical order when tags are preent' do
        post = make_post(extra_yaml: 'Tags: foo bar')
        bookmark_span = post.content[%r{<span class="bookmark">[^<]*(?:<[^>]+>[^<]*)*</span>}]

        _(bookmark_span.index('foo')).must_be :>, bookmark_span.index('bar')
      end

      it 'omits tag links when the post has no tags' do
        post = make_post

        _(post.content).wont_include '/tags/'
      end

      it 'omits the trailing space inside the bookmark span when the post has no tags' do
        post = make_post

        _(post.content).must_include ']</span>'
        _(post.content).wont_include '] </span>'
      end

      it 'omits tag links when blog_tags_path is not configured' do
        setup_config(blog_tags_path: nil)
        post = make_post(extra_yaml: 'Tags: foo bar')

        _(post.content).wont_include '/tags/'
      end
    end

    describe '#feed_snippet' do
      it 'returns rendered HTML of the content without the title heading' do
        post = make_post(title: 'My Post')
        snippet = post.feed_snippet

        _(snippet).must_include '<p>'
        _(snippet).wont_match(/^### My Post/)
        _(snippet).wont_include '<h3>'
      end
    end

    describe '#title' do
      it 'extracts the title from the first markup heading' do
        post = make_post(title: 'Heading Title')

        _(post.title).must_equal 'Heading Title'
      end
    end

    describe '#draft?' do
      it 'returns false when the Draft key is not in frontmatter' do
        _(make_post.draft?).must_equal false
      end

      it 'returns true when the Draft key is present in frontmatter' do
        _(make_post(extra_yaml: 'Draft: true').draft?).must_equal true
      end

      it 'returns true when Draft key is present with no value' do
        _(make_post(extra_yaml: 'Draft:').draft?).must_equal true
      end
    end

    describe '#report_field_summary' do
      it 'prints creation, path, and title separated by pipes' do
        post = make_post(creation: Time.utc(2024, 1, 5, 0, 0, 0), name: 'my-post', title: 'My Title')

        out, = capture_io { post.report_field_summary }

        _(out).must_include ' 5 Jan 2024'
        _(out).must_include 'my-post.md'
        _(out).must_include 'My Title'
        _(out).must_include ' | '
      end
    end
  end
end
