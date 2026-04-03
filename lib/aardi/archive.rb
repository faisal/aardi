# frozen_string_literal: true

module Aardi
  class Archive < AbstractBlog
    def initialize(posts, archive_path)
      @posts = posts
      @archive_path = archive_path
    end

    def content
      year_fmt = "| %<year>s | %<months>s \n"
      month_fmt = "[&nbsp;%<count>s&nbsp;](#{Aardi.config[:site_url]}/%<archive_path>s/%<year>s/%<month>s/)"

      "#{header}#{years.map { |year| year.archive_row(year_fmt, month_fmt) }.join}"
    end

    def target_path = "./#{@archive_path}/index.html"

    def title = Aardi.config[:blog_archive_title]

    private

    def calendar
      index = Hash.new { |hash, year| hash[year] = Year.new(year, @archive_path) }
      @posts.each do |post|
        index[post.year] << post
      end

      index
    end

    def children
      years
    end

    def header
      "# #{Aardi.config[:blog_archive_title]}

||Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec|
|---|---|---|---|---|---|---|---|---|---|---|---|---|
"
    end

    def years
      @years ||= calendar.values.sort_by { |date| -date.key }
    end
  end
end
