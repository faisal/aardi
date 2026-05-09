# frozen_string_literal: true

module Aardi
  class Post < AbstractBlog
    include AbstractPageSupport

    def initialize(path)
      @path = path
      parse_source path

      raise "#{path}: missing Creation metadata" unless metadata['Creation']
    end

    def content
      @content ||= "#{@src_content}\n<div>#{PostBookmarkLine.new(self)}</div>\n"
    end

    def creation = metadata['Creation']

    def feed_snippet
      @feed_snippet ||= Aardi.ledger[:renderer].markup_snippet(@src_content.sub(/\A(### .*\n)?\n+/, ''))
    end

    def name = File.basename(@path, '.*')

    def report_field_summary
      creation_header = creation.strftime('%e %b %Y')
      puts "#{creation_header} | #{@path} | #{title}"
    end

    def tags
      @tags ||= metadata['Tags']&.split&.sort
    end

    def target_path
      "./#{short_target}.html"
    end

    def updated = metadata['Updated'] || creation

    def url = "#{Aardi.config[:site_url]}/#{short_target}"

    private

    def short_target
      "#{Aardi.config[:blog_archive_path]}/#{creation.strftime('%Y/%m/%d')}/#{name}"
    end
  end
end
