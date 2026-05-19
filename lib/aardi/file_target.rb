# frozen_string_literal: true

module Aardi
  class FileTarget
    def initialize(src, target_path)
      renderer = Aardi.renderer
      @src = src
      @path = target_path
      @content_hashes = renderer.content_hashes
      @html_files = renderer.html_files
    end

    # :reek:TooManyStatements
    def write
      hash = @src.output_hash
      return { @path => hash } unless should_write?

      FileUtils.mkdir_p(File.dirname(@path))
      File.write(@path, "#{@src.output}\n")
      puts("Wrote #{@path}")
      { @path => hash }
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

      # in case cache missing (or corrupt) yet file good.
      @src.output != File.read(@path).strip
    end
  end
end
