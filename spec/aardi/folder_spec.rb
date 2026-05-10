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
  end
end
