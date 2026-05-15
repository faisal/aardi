# frozen_string_literal: true

module Aardi
  # :reek:TooManyInstanceVariables
  class Day < AbstractBlog
    def initialize(year, month, key, archive_path, tag = nil)
      @year = year
      @month = month
      @key = key
      @archive_path = archive_path
      @tag = tag
      @posts = []
    end

    def <<(post)
      @posts << post
    end

    def content
      @content ||= begin
        sorted_posts = @posts.sort_by(&:creation)
        posts_content = sorted_posts.reverse.map(&:content)
        "# #{title}\n#{posts_content.join}"
      end
    end

    def count = @posts.count

    def target_path
      "./#{@archive_path}/#{@year}/#{@month}/#{self}/index.html"
    end

    private

    def base_title = date.strftime('%A, %-e %B %Y')

    def children
      @posts
    end

    def date = Date.new(@year.key, @month.key, @key)

    def to_s = @key.to_s.rjust(2, '0')
  end
end
