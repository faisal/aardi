# frozen_string_literal: true

module Aardi
  module AbstractPageSupport
    attr_reader :metadata, :mtime

    def parse_source(path)
      yaml_part, _, @src_content = File.read(path, encoding: 'utf-8').rpartition("\n----\n")
      @metadata = YAML.safe_load(yaml_part, permitted_classes: [Time]) || {}
      @mtime = File.mtime(path).utc
    end

    def title
      metadata['Title'] || @src_content[/\A(?:#+ +)?([^\n]+)/, 1]
    end
  end
end
