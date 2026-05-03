# frozen_string_literal: true

module Aardi
  class Post < AbstractBlog
    include AbstractPageSupport

    def initialize(path, config:, ledger:)
      super(config:, ledger:)
      @path = path
      parse_source path
      raise "#{path}: missing Creation metadata" unless metadata['Creation']
    end

    def content
      @content ||= "#{@src_content}\n<div>#{PostBookmarkLine.new(self, config: @config)}</div>\n"
    end

    def creation = metadata['Creation']

    def feed_snippet
      @feed_snippet ||= begin
        clean_content = @src_content.sub(/\A(### .*\n)?\n+/, '')
        render_markup(clean_content).strip
      end
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

    def url = "#{@config[:site_url]}/#{short_target}"

    private

    def render_markup(content)
      @ledger[:custom_renderer].reset
      @ledger[:markdown_renderer].render(content)
    end

    def short_target
      "#{@config[:blog_archive_path]}/#{creation.strftime('%Y/%m/%d')}/#{name}"
    end
  end
end
