# frozen_string_literal: true

# Reusable stub that satisfies the Post interface for aggregate-class tests.
# :reek:TooManyInstanceVariables
class StubPost
  attr_reader :mtime, :creation, :updated, :year, :month, :day, :title, :name, :url, :path

  def initialize(creation_time, title: 'Test Post', name: 'test-post')
    @creation = creation_time
    @updated = creation_time
    @year = creation_time.year
    @month = creation_time.month
    @day = creation_time.day
    @title = title
    @name = name
    @url = "http://example.com/blog/#{format('%<y>04d/%<m>02d/%<d>02d', y: @year, m: @month, d: @day)}/#{name}"
    @mtime = creation_time
    @path = "posts/#{name}.md"
  end

  def content
    "### #{@title}\n\nContent here.\n"
  end

  def feed_snippet
    "<p>Snippet for #{@title}</p>"
  end

  def report_field_summary
    puts "#{@creation.strftime('%-e %b %Y')} | #{@path} | #{@title}"
  end
end
