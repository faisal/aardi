# frozen_string_literal: true

# :reek:TooManyInstanceVariables
class StubPost
  attr_reader :mtime, :creation, :updated, :title, :name, :url, :path, :tags

  def initialize(creation, title: 'Test Post', name: 'test-post', tags: [])
    @creation = creation
    @updated = creation
    @title = title
    @name = name
    @url = "http://example.com/blog/#{creation.strftime('%Y/%m/%d')}/#{name}"
    @mtime = creation
    @path = "posts/#{name}.md"
    @tags = tags
  end

  def content
    "### #{@title}\n\nContent here.\n"
  end

  def feed_snippet
    "<p>Snippet for #{@title}</p>"
  end
end
