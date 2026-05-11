# frozen_string_literal: true

module Aardi
  class TagDispatcher
    def initialize
      @index = {}
      @counts = Hash.new(0)
    end

    def <<(post)
      post.tags&.each do |tag|
        tag_blog_for(tag) << post
        @counts[tag] += 1
      end
    end

    def archive_tag_index = tag_index

    def children = empty? ? [] : [tag_index, *@index.values]

    def empty? = @index.empty?

    private

    def tag_blog_for(tag)
      @index[tag] ||= TagBlog.new(tag)
    end

    def tag_index
      @tag_index ||= Tags.new(@counts)
    end
  end
end
