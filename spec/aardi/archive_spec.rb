# frozen_string_literal: true

require 'spec_helper'

class ArchiveSpec < Minitest::Spec
  describe Aardi::Archive do
    before do
      @config = setup_config
      @ledger = Aardi::Ledger.new
    end

    def make_archive(posts)
      calendar = make_posts(posts, config: @config, ledger: @ledger).calendar
      Aardi::Archive.new(calendar, 'blog', config: @config, ledger: @ledger)
    end

    describe '#title' do
      it 'returns the blog_archive_title from config' do
        archive = make_archive([])

        _(archive.title).must_equal 'Blog Archive'
      end
    end

    describe '#target_path' do
      it 'uses the archive_path' do
        target_path = make_archive([]).target_path

        _(target_path).must_equal './blog/index.html'
      end
    end

    describe 'with tag_index' do
      def make_archive_with_tag_index(posts)
        tag_index = Aardi::TagIndex.new({ 'ruby' => 2, 'rails' => 1 }, config: @config, ledger: @ledger)
        calendar = make_posts(posts, config: @config, ledger: @ledger).calendar
        Aardi::Archive.new(calendar, 'blog', config: @config, ledger: @ledger, tag_index: tag_index)
      end

      it 'includes tag links in content' do
        posts = [StubPost.new(Time.utc(2024, 1, 1))]
        content = make_archive_with_tag_index(posts).content

        _(content).must_include '**What**:'
        _(content).must_include '[ruby]'
      end
    end

    describe '#content' do
      it 'includes a archive table header row' do
        content = make_archive([]).content

        _(content).must_match(/\|Jan\|.*\|Dec\|/)
      end

      it 'includes the archive title as a heading' do
        content = make_archive([]).content

        _(content).must_match(/\A# Blog Archive/)
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
