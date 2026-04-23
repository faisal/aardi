# frozen_string_literal: true

module Aardi
  class Year < AbstractBlog
    def initialize(key, archive_path, config:, ledger:)
      super(config:, ledger:)
      @key = key
      @archive_path = archive_path
      @index = Hash.new do |hash, month|
        hash[month] = Month.new(self, month, archive_path, config: config, ledger: ledger)
      end
    end

    def <<(post)
      @index[post.month] << post
    end

    def archive_row(year_fmt, month_fmt)
      months_map = (1..12).map { |month| @index[month].archive_cell(month_fmt) }.join
      format(year_fmt, year: to_s, months: months_map)
    end

    def content
      "# #{title}\n#{months.map { |month| month_link(month) }.join("\n")}"
    end

    def target_path
      "./#{@archive_path}/#{self}/index.html"
    end

    def title = to_s

    private

    def children
      months
    end

    def month_link(month)
      "- [#{Date::MONTHNAMES[month.key]}](#{@config[:site_url]}/#{@archive_path}/#{self}/#{month}/)"
    end

    def months
      @months ||= @index.values.sort_by { |value| -value.key }
    end

    def to_s = key.to_s
  end
end
