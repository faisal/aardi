# frozen_string_literal: true

module Aardi
  class Archive < AbstractBlog
    def initialize(posts, archive_path, config:, ledger:)
      super(config:, ledger:)
      @posts = posts
      @archive_path = archive_path
    end

    def content
      year_fmt = "| %<year>s | %<months>s \n"
      month_fmt = "[&nbsp;%<count>s&nbsp;](#{@config[:site_url]}/%<archive_path>s/%<year>s/%<month>s/)"

      "#{header}#{years.map { |year| year.archive_row(year_fmt, month_fmt) }.join}"
    end

    def target_path = "./#{@archive_path}/index.html"

    def title = @config[:blog_archive_title]

    private

    def calendar
      index = Hash.new { |hash, year| hash[year] = Year.new(year, @archive_path, config: @config, ledger: @ledger) }
      @posts.each do |post|
        index[post.year] << post
      end

      index
    end

    def children
      years
    end

    def header
      "# #{title}

||Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec|
|---|---|---|---|---|---|---|---|---|---|---|---|---|
"
    end

    def years
      @years ||= calendar.values.sort_by { |date| -date.key }
    end
  end
end
