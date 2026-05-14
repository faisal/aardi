# frozen_string_literal: true

module Aardi
  class Archive < AbstractBlog
    def initialize(archive_path, tag = nil, tags = nil)
      @archive_path = archive_path
      @tag = tag
      @tags = tags
      @index = Hash.new { |hash, year| hash[year] = Year.new(year, @archive_path, @tag) }
    end

    def <<(post)
      @index[post.creation.year] << post
    end

    def content
      year_fmt = "| %<year>s | %<months>s \n"
      month_fmt = "[&nbsp;%<count>s&nbsp;](#{Aardi.config[:site_url]}/%<archive_path>s/%<year>s/%<month>s/)"

      rows = years.map { |year| year.archive_row(year_fmt, month_fmt) }.join
      "#{title_heading}#{tag_list}**When**:\n\n#{table_header}#{rows}"
    end

    def target_path = "./#{@archive_path}/index.html"

    def title
      base_title = Aardi.config[:blog_archive_title]
      return "#{base_title} - #{@tag}" if @tag

      base_title
    end

    private

    def children
      years
    end

    def table_header
      "||Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec|
|---|---|---|---|---|---|---|---|---|---|---|---|---|
"
    end

    def tag_list
      return '' unless @tags
      return '' if @tags.empty?

      "**What**: #{@tags.inline_links}\n\n"
    end

    def title_heading = "# #{title}\n\n"

    def years
      @years ||= @index.values.sort_by { |date| -date.key }
    end
  end
end
