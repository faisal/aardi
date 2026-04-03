# frozen_string_literal: true

module Aardi
  class FileTarget
    def initialize(src, target_path)
      @src = src
      @path = target_path
      @content_hashes = Aardi.ledger[:content_hashes]
    end

    # :reek:TooManyStatements
    def write
      do_write = should_write?
      update_hash
      return unless do_write

      FileUtils.mkdir_p(File.dirname(@path))
      File.write(@path, "#{@src.output}\n")
      puts("Wrote #{@path}")
    end

    private

    def file_exists?
      File.exist? @path
    end

    def output_hash_changed?
      @src.output_hash != @content_hashes[@path]
    end

    def should_write?
      return true unless file_exists?
      return false unless output_hash_changed?

      @src.output != File.read(@path).strip
    end

    def update_hash
      @content_hashes[@path] = @src.output_hash
    end
  end
end
