# frozen_string_literal: true

require 'spec_helper'

class ArchiveSpec < Minitest::Spec
  describe Aardi::Archive do
    before do
      setup_config
    end

    def make_archive(posts)
      archive = Aardi::Archive.new('blog')
      posts.each { |post| archive << post }
      archive
    end

    describe '#title' do
      it 'returns the blog_archive_title from config' do
        _(make_archive([]).title).must_equal 'Blog Archive'
      end
    end

    describe '#target_path' do
      it 'uses the archive_path' do
        _(make_archive([]).target_path).must_equal './blog/index.html'
      end
    end

    describe 'with tag_index' do
      def make_archive_with_tag_index(posts)
        tag_index = Aardi::Tags.new({ 'foo' => 2, 'bar' => 1 })
        archive = Aardi::Archive.new('blog', tag_index: tag_index)
        posts.each { |post| archive << post }
        archive
      end

      it 'includes tag links in content' do
        posts = [StubPost.new(Time.utc(2024, 1, 1))]
        content = make_archive_with_tag_index(posts).content

        _(content).must_include '**What**:'
        _(content).must_include '[foo]'
      end

      it 'omits the **What**: line when the Tags is empty' do
        empty_index = Aardi::Tags.new({})
        archive = Aardi::Archive.new('blog', tag_index: empty_index)

        _(archive.content).wont_include '**What**:'
      end
    end

    describe '#content' do
      it 'includes a archive table header row' do
        _(make_archive([]).content).must_match(/\|Jan\|.*\|Dec\|/)
      end

      it 'includes the archive title as a heading' do
        _(make_archive([]).content).must_match(/\A# Blog Archive/)
      end

      it 'includes rows for each year that has posts' do
        posts = [StubPost.new(Time.utc(2023, 5, 1)), StubPost.new(Time.utc(2024, 3, 1))]
        content = make_archive(posts).content

        _(content).must_include '2023'
        _(content).must_include '2024'
      end

      it 'lists years in reverse chronological order' do
        posts = [StubPost.new(Time.utc(2022, 1, 1)), StubPost.new(Time.utc(2024, 1, 1))]
        content = make_archive(posts).content

        _(content.index('2024')).must_be :<, content.index('2022')
      end
    end
  end
end
