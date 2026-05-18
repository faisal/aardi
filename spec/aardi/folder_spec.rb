# frozen_string_literal: true

require 'spec_helper'

class FolderSpec < Minitest::Spec
  describe Aardi::Folder do
    before do
      setup_config
    end

    describe '.new' do
      it 'accepts a path argument' do
        folder = Aardi::Folder.new('.')

        _(folder).must_be_kind_of Aardi::Folder
      end
    end

    describe '#mtime' do
      it 'returns nil when no children have a mtime' do
        Dir.mktmpdir do |dir|
          FileUtils.mkdir(File.join(dir, 'empty_sub'))
          folder = Aardi::Folder.new(dir)

          _(folder.mtime).must_be_nil
        end
      end

      it 'does not raise when some children have nil mtime and others do not' do
        Dir.mktmpdir do |dir|
          FileUtils.mkdir(File.join(dir, 'empty_sub'))
          File.write(File.join(dir, 'page.md'), "Title: Test\n\nContent")
          folder = Aardi::Folder.new(dir)

          _(folder.mtime).must_be_kind_of Time
        end
      end
    end

    describe '#render' do
      before do
        @tmpdir = Dir.mktmpdir
        @original_dir = Dir.pwd
        Dir.chdir(@tmpdir)
        @sitemap = Aardi::Sitemap.new
        @renderer = make_renderer(
          html_files: Set.new,
          content_hashes: Aardi::ContentHashes.new(File.join(@tmpdir, 'hashes.txt')),
          sitemap: @sitemap
        )
      end

      after do
        Dir.chdir(@original_dir)
        FileUtils.rm_rf(@tmpdir)
      end

      it "renders contained .md pages when path is '.'" do
        File.write(File.join(@tmpdir, 'page.md'), "Title: P\n\n----\n# P\n\nText.\n")

        capture_io { Aardi::Folder.new('.').render(@renderer) }

        _(File.exist?(File.join(@tmpdir, 'page.html'))).must_equal true
      end

      it 'returns a hash mapping rendered page paths to their checksums' do
        File.write(File.join(@tmpdir, 'page.md'), "Title: P\n\n----\n# P\n\nText.\n")
        result = nil
        capture_io { result = Aardi::Folder.new('.').render(@renderer) }

        _(result).must_be_kind_of Hash
        _(result.keys).must_include './page.html'
      end

      it "does not record sitemap mtime when path is '.'" do
        File.write(File.join(@tmpdir, 'page.md'), "Title: P\n\n----\n# P\n\nText.\n")

        capture_io { Aardi::Folder.new('.').render(@renderer) }

        _(@sitemap.urls['/'].key?(:lastmod)).must_equal false
      end

      it "records sitemap mtime for the folder's normalized path when path is not '.'" do
        FileUtils.mkdir_p(File.join(@tmpdir, 'section'))
        File.write(File.join(@tmpdir, 'section', 'page.md'), "Title: P\n\n----\n# P\n\nText.\n")
        setup_config(template_path: File.join(SpecHelpers::SAMPLES_DIR, 'minimal_template.html'),
                     sitemap_entries: { '/section/' => 'weekly' })
        section_sitemap = Aardi::Sitemap.new
        section_renderer = make_renderer(
          html_files: Set.new,
          content_hashes: Aardi::ContentHashes.new(File.join(@tmpdir, 'hashes2.txt')),
          sitemap: section_sitemap
        )

        capture_io { Aardi::Folder.new('./section').render(section_renderer) }

        _(section_sitemap.urls['/section/'][:lastmod]).wont_be_nil
      end
    end
  end
end
