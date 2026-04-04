# frozen_string_literal: true

require "spec_helper"

class ContentHashesSpec < Minitest::Spec
  describe Aardi::ContentHashes do
    describe "when file does not exist" do
      subject { Aardi::ContentHashes.new("/nonexistent_hashes_file") }

      it "starts with no stored hashes" do
        expect(subject["/some/path"]).must_be_nil
      end
    end

    describe "when file exists" do
      it "reads existing hashes" do
        Tempfile.create(["hashes", ".txt"]) do |file|
          file.write("/path/to/file: 12345\n")
          file.flush
          hashes = Aardi::ContentHashes.new(file.path)
          expect(hashes["/path/to/file"]).must_equal 12_345
        end
      end
    end

    describe "#[]=" do
      subject { Aardi::ContentHashes.new("/nonexistent_hashes_file") }

      it "stores a hash for a path" do
        subject["/foo"] = 99
        expect(subject["/foo"]).must_equal 99
      end
    end

    describe "#write" do
      it "does not write when hashes are unchanged" do
        Dir.mktmpdir do |dir|
          path = File.join(dir, "hashes.txt")
          File.write(path, "/a: 100\n")
          hashes = Aardi::ContentHashes.new(path)
          # Do not modify; write should be a no-op
          out, = capture_io { hashes.write }
          expect(out).must_be_empty
          expect(File.read(path)).must_equal "/a: 100\n"
        end
      end

      it "writes updated hashes and prints a message" do
        Dir.mktmpdir do |dir|
          path = File.join(dir, "hashes.txt")
          hashes = Aardi::ContentHashes.new(path)
          hashes["/b"] = 200
          out, = capture_io { hashes.write }
          expect(out).must_include "Wrote:"
          expect(File.read(path)).must_include "/b: 200"
        end
      end

      it "sorts hashes alphabetically when writing" do
        Dir.mktmpdir do |dir|
          path = File.join(dir, "hashes.txt")
          hashes = Aardi::ContentHashes.new(path)
          hashes["/z"] = 1
          hashes["/a"] = 2
          capture_io { hashes.write }
          lines = File.readlines(path)
          expect(lines.first).must_include "/a"
        end
      end
    end
  end
end
