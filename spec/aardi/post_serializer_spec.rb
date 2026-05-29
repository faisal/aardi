# frozen_string_literal: true

require 'spec_helper'
require 'aardi/post_serializer'
require 'aardi/post_content'

class PostSerializerSpec < Minitest::Spec
  describe Aardi::PostSerializer do
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

    subject { Aardi::PostSerializer.new }

    describe '#dump' do
      it 'writes Title, Creation, the separator and the body' do
        text = subject.dump(Aardi::PostContent.fresh(title: 'Hi', body: "Body.\n", tags: [],
                                                     creation: Time.utc(2024, 1, 5, 9, 0, 0)))

        _(text).must_include 'Title: Hi'
        _(text).must_include "\n----\n"
        _(text).must_include 'Body.'
      end

      it 'omits Tags and Updated when absent' do
        text = subject.dump(Aardi::PostContent.fresh(title: 'Hi', body: "b\n", tags: [],
                                                     creation: Time.utc(2024, 1, 5)))

        _(text).wont_match(/^Tags:/)
        _(text).wont_match(/^Updated:/)
      end

      it 'includes Tags and Updated when present' do
        text = subject.dump(Aardi::PostContent.new(title: 'Hi', body: "b\n", tags: %w[a b],
                                                   creation: Time.utc(2024, 1, 5),
                                                   updated: Time.utc(2024, 2, 1)))

        _(text).must_match(/^Tags: a b/)
        _(text).must_match(/^Updated:/)
      end
    end

    describe '#write and #load' do
      it 'round-trips content written to disk back into a PostRecord' do
        path = File.join('posts', 'a', 'post.md')
        subject.write(path, Aardi::PostContent.fresh(title: 'Round', body: "trip\n",
                                                     tags: %w[zeta alpha],
                                                     creation: Time.utc(2024, 1, 5, 9, 0, 0)))
        record = subject.load(path, 'a/post.md')

        _(record.postid).must_equal 'a/post.md'
        _(record.title).must_equal 'Round'
        _(record.body).must_equal "trip\n"
        _(record.tags).must_equal %w[alpha zeta]
        _(record.url).must_include 'http://example.com/blog/2024/01/05/'
      end
    end
  end
end
