# frozen_string_literal: true

module Aardi
  module AbstractPageSupport
    attr_reader :metadata, :mtime

    def parse_source(path)
      File.open(path, encoding: 'utf-8') do |file|
        parts = file.read.rpartition("\n----\n")
        @metadata = YAML.safe_load(parts.first, permitted_classes: [Time]) || {}
        @src_content = parts.last
        @mtime = file.mtime.utc
      end
    end

    def title
      metadata['Title'] || @src_content.split("\n").first.sub(/^#+ /, '')
    end
  end
end
