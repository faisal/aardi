# frozen_string_literal: true

require "spec_helper"

class FileTargetSpec < Minitest::Spec
  describe Aardi::FileTarget do
    before do
      setup_config
      @tmpdir = Dir.mktmpdir
      Aardi.ledger[:content_hashes] = Aardi::ContentHashes.new(File.join(@tmpdir, "hashes.txt"))
    end

    after { FileUtils.rm_rf(@tmpdir) }

    def target_path(name = "out.html")
      File.join(@tmpdir, name)
    end

    it "writes the file when it does not exist" do
      src = Aardi::Content.new("Hello")
      out, = capture_io { Aardi::FileTarget.new(src, target_path).write }
      expect(File.read(target_path).strip).must_equal "Hello"
      expect(out).must_include "Wrote"
    end

    it "creates parent directories as needed" do
      path = File.join(@tmpdir, "sub", "dir", "file.html")
      src = Aardi::Content.new("content")
      capture_io { Aardi::FileTarget.new(src, path).write }
      expect(File.exist?(path)).must_equal true
    end

    it "skips writing when file content is unchanged" do
      path = target_path
      File.write(path, "Hello\n")
      src = Aardi::Content.new("Hello")
      # Pre-seed the hash to match
      Aardi.ledger[:content_hashes][path] = src.output_hash
      out, = capture_io { Aardi::FileTarget.new(src, path).write }
      expect(out).must_be_empty
    end

    it "overwrites when content has changed" do
      path = target_path
      File.write(path, "Old content\n")
      # Seed a different hash so the hash-change check passes
      Aardi.ledger[:content_hashes][path] = 0
      src = Aardi::Content.new("New content")
      capture_io { Aardi::FileTarget.new(src, path).write }
      expect(File.read(path).strip).must_equal "New content"
    end

    it "updates content hash after writing" do
      path = target_path
      src = Aardi::Content.new("data")
      capture_io { Aardi::FileTarget.new(src, path).write }
      expect(Aardi.ledger[:content_hashes][path]).must_equal src.output_hash
    end
  end
end
