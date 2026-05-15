# frozen_string_literal: true

require 'spec_helper'

class FolderSpec < Minitest::Spec
  describe Aardi::Folder do
    before do
      setup_config
      setup_ledger
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
        Aardi.ledger[:html_files] = Set.new
        Aardi.ledger[:content_hashes] = Aardi::ContentHashes.new(File.join(@tmpdir, 'hashes.txt'))
        Aardi.ledger[:sitemap] = Aardi::Sitemap.new
      end

      after do
        Dir.chdir(@original_dir)
        FileUtils.rm_rf(@tmpdir)
      end

      it "renders contained .md pages when path is '.'" do
        File.write(File.join(@tmpdir, 'page.md'), "Title: P\n\n----\n# P\n\nText.\n")

        capture_io { Aardi::Folder.new('.').render }

        _(File.exist?(File.join(@tmpdir, 'page.html'))).must_equal true
      end

      it "does not record sitemap mtime when path is '.'" do
        File.write(File.join(@tmpdir, 'page.md'), "Title: P\n\n----\n# P\n\nText.\n")

        capture_io { Aardi::Folder.new('.').render }

        _(Aardi.ledger[:sitemap].urls['/'].key?(:lastmod)).must_equal false
      end

      it "records sitemap mtime for the folder's normalized path when path is not '.'" do
        FileUtils.mkdir_p(File.join(@tmpdir, 'section'))
        File.write(File.join(@tmpdir, 'section', 'page.md'), "Title: P\n\n----\n# P\n\nText.\n")
        setup_config(template_path: File.join(SpecHelpers::SAMPLES_DIR, 'minimal_template.html'),
                     sitemap_entries: { '/section/' => 'weekly' })
        setup_ledger
        Aardi.ledger[:html_files] = Set.new
        Aardi.ledger[:content_hashes] = Aardi::ContentHashes.new(File.join(@tmpdir, 'hashes.txt'))
        Aardi.ledger[:sitemap] = Aardi::Sitemap.new

        capture_io { Aardi::Folder.new('./section').render }

        _(Aardi.ledger[:sitemap].urls['/section/'][:lastmod]).wont_be_nil
      end
    end
  end
end
