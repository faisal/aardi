# frozen_string_literal: true

module Aardi
  module AbstractPageSupport
    def metadata
      @metadata
    end

    def mtime
      @mtime
    end

    def parse_source(path)
      File.open(path, encoding: 'utf-8') do |file|
        parts = file.read.rpartition("\n----\n")
        @metadata = Metadata.new(parts.first, path)
        @src_content = parts.last
        @mtime = file.mtime.utc
      end
    end

    def title
      metadata.title || @src_content[/\A(?:#+ +)?([^\n]+)/, 1]
    end
  end
end
