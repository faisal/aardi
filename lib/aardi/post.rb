# frozen_string_literal: true

module Aardi
  class Post < AbstractBlog
    include AbstractPageSupport

    def initialize(path)
      @path = path
      parse_source path
    end

    def content
      "#{@src_content}\n<div><span class=\"bookmark\">[<a href=\"#{url}\">bookmark</a>]</span></div>\n"
    end

    def creation = metadata["Creation"]

    def day = creation.day

    def feed_snippet
      clean_content = @src_content.sub(/\A(### .*\n)?\n+/, "")
      render_markup(clean_content).strip
    end

    def month = creation.month

    def name = File.basename(@path, ".*")

    def report_field_summary
      creation_header = creation.strftime("%e %b %Y")
      puts "#{creation_header} | #{@path} | #{title}"
    end

    def target_path
      "./#{short_target}.html"
    end

    def updated = metadata["Updated"] || creation

    def url = "#{Aardi.config[:site_url]}/#{short_target}"

    def year = creation.year

    private

    def render_markup(content)
      ledger = Aardi.ledger
      ledger[:custom_renderer].reset
      ledger[:markdown_renderer].render(content)
    end

    def short_target
      "#{Aardi.config[:blog_archive_path]}/#{creation.strftime("%Y/%m/%d")}/#{name}"
    end
  end
end
