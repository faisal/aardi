# frozen_string_literal: true

module Aardi
  class Month < AbstractBlog
    def initialize(year, key, archive_path)
      @year = year
      @key = key
      @archive_path = archive_path
      @index = Hash.new { |hash, day| hash[day] = Day.new(year, self, day, archive_path) }
    end

    def <<(post)
      @index[post.day] << post
    end

    def archive_cell(month_fmt)
      cell = count.zero? ? '' : format(month_fmt, count:, archive_path: @archive_path, year: @year, month: self)
      "#{cell} |"
    end

    def content
      @content ||= begin
        days_content = days.map { |day| "##{day.content}" }.join
        "# #{title}\n#{days_content}"
      end
    end

    def count = days.sum(&:count)

    def target_path
      "./#{@archive_path}/#{@year}/#{self}/index.html"
    end

    def title = Date.new(@year.key, @key).strftime('%B %Y')

    def to_s = @key.to_s.rjust(2, '0')

    private

    def children
      days
    end

    def days
      @days ||= @index.values.sort_by { |value| -value.key }
    end
  end
end
