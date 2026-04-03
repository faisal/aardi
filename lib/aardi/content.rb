# frozen_string_literal: true

module Aardi
  class Content
    def initialize(src_content)
      @src_content = src_content.strip
    end

    def output
      @output ||= @src_content
    end

    def output_hash
      @output_hash ||= Zlib.crc32(output)
    end
  end
end
