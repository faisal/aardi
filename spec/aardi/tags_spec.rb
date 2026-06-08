# frozen_string_literal: true

require 'spec_helper'

class TagsSpec < Minitest::Spec
  describe Aardi::Tags do
    before do
      setup_config
      @tags = Aardi::Tags.new
    end

    def tagged_post(tags)
      StubPost.new(Time.utc(2024, 1, 1), tags:)
    end

    describe '#target_path' do
      it 'returns the tags index path using config values' do
        _(@tags.target_path).must_equal './tags/index.html'
      end
    end

    describe '#title' do
      it 'returns "Tags"' do
        _(@tags.title).must_equal 'Tags'
      end
    end

    describe '#empty?' do
      it 'is true with no posts' do
        _(@tags.empty?).must_equal true
      end

      it 'is false once a tagged post is added' do
        @tags << tagged_post(%w[foo])

        _(@tags.empty?).must_equal false
      end

      it 'remains true when an untagged post is added' do
        @tags << tagged_post([])

        _(@tags.empty?).must_equal true
      end
    end

    describe '#<<' do
      it 'distributes a post to each of its tag blogs' do
        post = tagged_post(%w[foo bar])
        @tags << post

        @tags.send(:children).grep(Aardi::TagBlog).each do |tag_blog|
          _(tag_blog.instance_variable_get(:@posts)).must_include post
        end
      end

      it 'ignores posts with no tags' do
        @tags << tagged_post([])

        _(@tags.send(:children)).must_equal []
      end
    end

    describe '#inline_links' do
      it 'includes the post count in parentheses after each link' do
        2.times { @tags << tagged_post(%w[foo]) }
        @tags << tagged_post(%w[bar])

        _(@tags.inline_links).must_match(/\[foo\]\([^)]+\) \(2\)/)
        _(@tags.inline_links).must_match(/\[bar\]\([^)]+\) \(1\)/)
      end
    end

    describe '#content' do
      it 'includes a markup link for each tag pointing to the correct URL' do
        @tags << tagged_post(%w[foo])

        _(@tags.content).must_include '[foo](http://example.com/tags/foo/)'
      end

      it 'reflects posts added after a reference is captured' do
        later = @tags
        @tags << tagged_post(%w[foo])
        @tags << tagged_post(%w[foo])
        @tags << tagged_post(%w[bar])

        _(later.content).must_match(/\[foo\]\([^)]+\) \(2\)/)
        _(later.content).must_match(/\[bar\]\([^)]+\) \(1\)/)
      end

      it 'includes the post count in parentheses' do
        3.times { @tags << tagged_post(%w[foo]) }

        _(@tags.content).must_include '(3)'
      end

      it 'sorts tags descending by count' do
        %w[zebra apple apple mango mango mango].each { |tag| @tags << tagged_post([tag]) }

        positions = %w[mango apple zebra].map { |tag| [@tags.content.index(tag)] }
        _(positions).must_equal positions.sort
      end

      it 'produces just the heading when no posts have been added' do
        _(@tags.content).must_equal "# Tags\n"
      end
    end

    describe '#children (private)' do
      it 'is empty before any tagged post is added' do
        _(@tags.send(:children)).must_equal []
      end

      it 'contains a TagBlog per tag once tagged posts are added' do
        @tags << tagged_post(%w[foo bar])

        classes = @tags.send(:children).map(&:class)
        _(classes.count { |tag_class| tag_class == Aardi::TagBlog }).must_equal 2
      end
    end

    describe '#tag_blogs' do
      it 'is empty when no tagged posts have been added' do
        _(@tags.tag_blogs).must_equal []
      end

      it 'returns a TagBlog for each tag present on added posts' do
        @tags << tagged_post(%w[foo bar])

        _(@tags.tag_blogs.map(&:class).uniq).must_equal [Aardi::TagBlog]
        _(@tags.tag_blogs.length).must_equal 2
      end
    end

    describe '#write_target (private)' do
      before do
        @tmpdir = Dir.mktmpdir
        @original_dir = Dir.pwd
        Dir.chdir(@tmpdir)
        make_renderer(
          html_files: Set.new,
          content_hashes: Aardi::ContentHashes.new(File.join(@tmpdir, 'hashes.txt'))
        )
      end

      after do
        Dir.chdir(@original_dir)
        FileUtils.rm_rf(@tmpdir)
      end

      it 'does not write the tags index when empty' do
        capture_io { @tags.send(:write_target) }

        _(File.exist?(File.join(@tmpdir, 'tags', 'index.html'))).must_equal false
      end

      it 'writes the tags index when not empty' do
        @tags << tagged_post(%w[foo])

        capture_io { @tags.send(:write_target) }

        _(File.exist?(File.join(@tmpdir, 'tags', 'index.html'))).must_equal true
      end
    end
  end
end
