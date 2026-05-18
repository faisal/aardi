# frozen_string_literal: true

module Aardi
  class Post < AbstractBlog
    include AbstractPageSupport

    def initialize(path, renderer)
      @path = path
      @renderer = renderer
      parse_source path

      raise "#{path}: missing Creation metadata" unless metadata.creation
    end

    def content
      @content ||= "#{@src_content}\n<div>#{PostBookmarkLine.new(self)}</div>\n"
    end

    def creation = metadata.creation

    def feed_snippet
      @feed_snippet ||= @renderer.markup_feed_snippet(@src_content)
    end

    def name = File.basename(@path, '.*')

    def report_field_summary
      creation_header = creation.strftime('%e %b %Y')
      puts "#{creation_header} | #{@path} | #{title}"
    end

    def tags = metadata.tags

    def target_path
      "./#{short_target}.html"
    end

    def updated = metadata.updated || creation

    def url = "#{Aardi.config[:site_url]}/#{short_target}"

    private

    def short_target
      "#{Aardi.config[:blog_archive_path]}/#{creation.strftime('%Y/%m/%d')}/#{name}"
    end
  end
end
