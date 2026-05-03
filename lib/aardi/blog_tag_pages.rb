# frozen_string_literal: true

module Aardi
  class BlogTagPages
    def initialize(config:, ledger:)
      @config = config
      @ledger = ledger
      @index = {}
    end

    def <<(post)
      post.tags&.each { |tag| tag_blog_for(tag) << post }
    end

    def archive_tag_index = empty? ? nil : tag_index

    def children = empty? ? [] : [tag_index, *@index.values]

    def empty? = @index.empty?

    private

    def tag_blog_for(tag)
      @index[tag] ||= TagBlog.new(tag, config: @config, ledger: @ledger)
    end

    def tag_index
      @tag_index ||= TagIndex.new(@index.keys, config: @config, ledger: @ledger)
    end
  end
end
