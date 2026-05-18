# frozen_string_literal: true

require 'spec_helper'

class ContentHashesSpec < Minitest::Spec
  describe Aardi::ContentHashes do
    describe 'when file does not exist' do
      subject do
        Aardi::ContentHashes.new('/nonexistent_hashes_file')
      end

      it 'starts with no stored hashes' do
        _(subject['/some/path']).must_be_nil
      end
    end

    describe 'when file exists' do
      it 'reads existing hashes' do
        Tempfile.create(['hashes', '.txt']) do |file|
          file.write("/path/to/file: 12345\n")
          file.flush
          hashes = Aardi::ContentHashes.new(file.path)
          _(hashes['/path/to/file']).must_equal 12_345
        end
      end
    end

    describe '#[]=' do
      subject do
        Aardi::ContentHashes.new('/nonexistent_hashes_file')
      end

      it 'stores a hash for a path' do
        subject['/foo'] = 99

        _(subject['/foo']).must_equal 99
      end
    end

    describe '#save' do
      it 'replaces stored hashes and writes them to disk in one call' do
        Dir.mktmpdir do |dir|
          path = File.join(dir, 'hashes.txt')
          hashes = Aardi::ContentHashes.new(path)
          capture_io { hashes.save({ '/saved' => 7 }) }

          _(File.read(path)).must_include '/saved: 7'
        end
      end
    end

    describe '#replace' do
      it 'replaces stored hashes so they are serialized on the next #write call' do
        Dir.mktmpdir do |dir|
          path = File.join(dir, 'hashes.txt')
          hashes = Aardi::ContentHashes.new(path)
          hashes.replace({ '/new/path' => 42 })
          capture_io { hashes.write }

          _(File.read(path)).must_include '/new/path: 42'
        end
      end

      it 'discards any previously stored hashes' do
        Dir.mktmpdir do |dir|
          path = File.join(dir, 'hashes.txt')
          hashes = Aardi::ContentHashes.new(path)
          hashes['/old'] = 1
          hashes.replace({ '/new' => 2 })
          capture_io { hashes.write }
          content = File.read(path)

          _(content).must_include '/new: 2'
          _(content).wont_include '/old'
        end
      end
    end

    describe '#write' do
      it 'does not write when hashes are unchanged' do
        Dir.mktmpdir do |dir|
          path = File.join(dir, 'hashes.txt')
          File.write(path, "/a: 100\n")
          hashes = Aardi::ContentHashes.new(path)
          out, = capture_io { hashes.write }

          _(out).must_be_empty
          _(File.read(path)).must_equal "/a: 100\n"
        end
      end

      it 'writes updated hashes and prints a message' do
        Dir.mktmpdir do |dir|
          path = File.join(dir, 'hashes.txt')
          hashes = Aardi::ContentHashes.new(path)
          hashes['/b'] = 200
          out, = capture_io { hashes.write }

          _(out).must_include 'Wrote:'
          _(File.read(path)).must_include '/b: 200'
        end
      end

      it 'sorts hashes alphabetically when writing' do
        Dir.mktmpdir do |dir|
          path = File.join(dir, 'hashes.txt')
          hashes = Aardi::ContentHashes.new(path)
          hashes['/z'] = 1
          hashes['/a'] = 2
          capture_io { hashes.write }
          lines = File.readlines(path)

          _(lines.first).must_include '/a'
        end
      end
    end
  end
end
