# frozen_string_literal: true

module Aardi
  # :reek:TooManyInstanceVariables
  # :reek:LongParameterList
  class Day < AbstractBlog
    # rubocop:disable Metrics/ParameterLists
    def initialize(year, month, key, archive_path, config:, ledger:, tag: nil)
      super(config:, ledger:)
      @year = year
      @month = month
      @key = key
      @archive_path = archive_path
      @tag = tag
      @posts = []
    end
    # rubocop:enable Metrics/ParameterLists

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

    def title
      base = date.strftime('%A, %-e %B %Y')
      if @tag
        "#{base} - #{@tag}"
      else
        base
      end
    end

    private

    def children
      @posts
    end

    def date = Date.new(@year.key, @month.key, @key)

    def to_s = @key.to_s.rjust(2, '0')
  end
end
