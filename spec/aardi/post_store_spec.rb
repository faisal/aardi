# frozen_string_literal: true

require 'spec_helper'
require 'aardi/post_store'

class PostStoreSpec < Minitest::Spec
  describe Aardi::PostStore do
    before do
      @tmpdir = Dir.mktmpdir
      @original_dir = Dir.pwd
      Dir.chdir(@tmpdir)
      FileUtils.mkdir_p('posts')
      setup_config(template_path: File.join(SpecHelpers::SAMPLES_DIR, 'minimal_template.html'),
                   blog_posts_path: './posts',
                   content_hashes_path: File.join(@tmpdir, 'hashes.txt'))
      make_renderer
    end

    after do
      Dir.chdir(@original_dir)
      FileUtils.rm_rf(@tmpdir)
    end

    subject { Aardi::PostStore.new }

    describe '#create' do
      it 'returns a postid and writes a markup file under the posts directory' do
        postid = subject.create(title: 'Hello', body: "World.\n", tags: [],
                                creation: Time.utc(2024, 1, 5, 9, 0, 0))

        _(File.exist?(File.join('posts', postid))).must_equal true
      end

      it 'writes Title and Creation frontmatter separated from the body' do
        postid = subject.create(title: 'Hello', body: "World.\n", tags: [],
                                creation: Time.utc(2024, 1, 5, 9, 0, 0))
        content = File.read(File.join('posts', postid))

        _(content).must_include 'Title: Hello'
        _(content).must_include "\n----\n"
        _(content).must_include 'World.'
      end

      it 'stores tags as a space-separated Tags declaration' do
        postid = subject.create(title: 'T', body: "b\n", tags: %w[zeta alpha],
                                creation: Time.utc(2024, 1, 5, 9, 0, 0))
        content = File.read(File.join('posts', postid))

        _(content).must_match(/^Tags: .*alpha/)
        _(content).must_match(/^Tags: .*zeta/)
      end
    end

    describe '#find' do
      it 'round-trips title and body through create' do
        postid = subject.create(title: 'My Title', body: "Some **markdown**.\n", tags: [],
                                creation: Time.utc(2024, 1, 5, 9, 0, 0))
        record = subject.find(postid)

        _(record.title).must_equal 'My Title'
        _(record.body).must_equal "Some **markdown**.\n"
      end

      it 'returns the creation as a Time and a date-based url' do
        postid = subject.create(title: 'T', body: "b\n", tags: [],
                                creation: Time.utc(2024, 1, 5, 9, 0, 0))
        record = subject.find(postid)

        _(record.creation).must_be_kind_of Time
        _(record.url).must_include 'http://example.com/blog/2024/01/05/'
      end

      it 'returns tags sorted alphabetically' do
        postid = subject.create(title: 'T', body: "b\n", tags: %w[zeta alpha],
                                creation: Time.utc(2024, 1, 5, 9, 0, 0))

        _(subject.find(postid).tags).must_equal %w[alpha zeta]
      end
    end

    describe '#recent' do
      it 'returns records newest-first, limited to the requested count' do
        subject.create(title: 'Old', body: "a\n", tags: [], creation: Time.utc(2024, 1, 1, 0, 0, 0))
        subject.create(title: 'New', body: "b\n", tags: [], creation: Time.utc(2024, 6, 1, 0, 0, 0))
        subject.create(title: 'Mid', body: "c\n", tags: [], creation: Time.utc(2024, 3, 1, 0, 0, 0))

        titles = subject.recent(2).map(&:title)

        _(titles).must_equal %w[New Mid]
      end
    end

    describe '#update' do
      it 'preserves the original creation while changing title and body' do
        postid = subject.create(title: 'Orig', body: "old\n", tags: [],
                                creation: Time.utc(2024, 1, 5, 9, 0, 0))
        subject.update(postid, title: 'Edited', body: "new\n", tags: [])
        record = subject.find(postid)

        _(record.title).must_equal 'Edited'
        _(record.body).must_equal "new\n"
        _(record.creation).must_equal Time.utc(2024, 1, 5, 9, 0, 0)
      end

      it 'records an Updated timestamp' do
        postid = subject.create(title: 'Orig', body: "old\n", tags: [],
                                creation: Time.utc(2024, 1, 5, 9, 0, 0))
        subject.update(postid, title: 'Edited', body: "new\n", tags: [])

        _(File.read(File.join('posts', postid))).must_match(/^Updated:/)
      end
    end

    describe '#set_tags' do
      it 'replaces the tags while preserving title, body, and creation' do
        postid = subject.create(title: 'Keep', body: "body\n", tags: %w[old],
                                creation: Time.utc(2024, 1, 5, 9, 0, 0))
        subject.set_tags(postid, %w[fresh news])
        record = subject.find(postid)

        _(record.tags).must_equal %w[fresh news]
        _(record.title).must_equal 'Keep'
        _(record.body).must_equal "body\n"
      end
    end

    describe '#delete' do
      it 'removes the post file' do
        postid = subject.create(title: 'Doomed', body: "x\n", tags: [],
                                creation: Time.utc(2024, 1, 5, 9, 0, 0))
        subject.delete(postid)

        _(File.exist?(File.join('posts', postid))).must_equal false
      end
    end
  end
end
