# frozen_string_literal: true

module Aardi
  # :reek:TooManyInstanceVariables
  class Month < AbstractBlog
    def initialize(year, key, archive_path, tag = nil)
      @year = year
      @key = key
      @archive_path = archive_path
      @index = Hash.new { |hash, day| hash[day] = Day.new(year, self, day, archive_path, tag) }
      @tag = tag
    end

    def <<(post)
      @index[post.creation.day] << post
    end

    def archive_cell(month_fmt)
      return ' |' if count.zero?

      "#{format(month_fmt, count:, archive_path: @archive_path, year: @year, month: self)} |"
    end

    def content
      @content ||= "# #{title}\n#{days.map { |day| "##{day.content}" }.join}"
    end

    def count = days.sum(&:count)

    def target_path
      "./#{@archive_path}/#{@year}/#{self}/index.html"
    end

    def to_s = @key.to_s.rjust(2, '0')

    private

    def base_title = Date.new(@year.key, @key).strftime('%B %Y')

    def children
      days
    end

    def days
      @days ||= @index.values.sort_by { |value| -value.key }
    end
  end
end
