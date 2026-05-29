# frozen_string_literal: true

require 'spec_helper'
require 'aardi/post_locator'

class PostLocatorSpec < Minitest::Spec
  describe Aardi::PostLocator do
    before do
      @tmpdir = Dir.mktmpdir
      @original_dir = Dir.pwd
      Dir.chdir(@tmpdir)
      FileUtils.mkdir_p('posts')
      setup_config(blog_posts_path: './posts',
                   content_hashes_path: File.join(@tmpdir, 'hashes.txt'))
    end

    after do
      Dir.chdir(@original_dir)
      FileUtils.rm_rf(@tmpdir)
    end

    subject { Aardi::PostLocator.new }

    describe '#new_postid' do
      it 'builds a sharded "<shard>/<unix>.md" id from the creation time' do
        creation = Time.utc(2024, 1, 5, 9, 0, 0)

        _(subject.new_postid(creation)).must_match(%r{\A[0-9a-z]+/#{creation.to_i}\.md\z})
      end
    end

    describe '#path_for' do
      it 'joins the posts root with the postid' do
        _(subject.path_for('a/1.md')).must_equal File.join('./posts', 'a/1.md')
      end
    end

    describe '#postid_for' do
      it 'is the inverse of path_for' do
        postid = 'a/1.md'

        _(subject.postid_for(subject.path_for(postid))).must_equal postid
      end
    end

    describe '#all_paths' do
      it 'globs markdown files anywhere under the posts root, ignoring others' do
        FileUtils.mkdir_p('posts/x')
        File.write('posts/x/1.md', 'a')
        File.write('posts/2.md', 'b')
        File.write('posts/skip.txt', 'c')
        paths = subject.all_paths

        _(paths).must_include './posts/2.md'
        _(paths).must_include './posts/x/1.md'
        _(paths.any? { |path| path.end_with?('.txt') }).must_equal false
      end
    end
  end
end
