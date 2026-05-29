# frozen_string_literal: true

require 'aardi'
require 'aardi/post_content'
require 'aardi/post_locator'
require 'aardi/post_serializer'

module Aardi
  # File-level CRUD for blog posts, used by the MarsEdit API. Delegates path
  # math to PostLocator and the on-disk format to PostSerializer, exposing a
  # keyword API in terms of PostRecord (reads) and PostContent (writes).
  class PostStore
    def initialize(locator: PostLocator.new, serializer: PostSerializer.new)
      @locator = locator
      @serializer = serializer
    end

    def all
      @locator.all_paths.map { |path| load(path) }
    end

    # :reek:LongParameterList
    def create(title:, body:, tags:, creation:)
      postid = @locator.new_postid(creation)
      persist(postid, PostContent.fresh(title:, body:, tags:, creation:))
      postid
    end

    def delete(postid)
      File.delete(@locator.path_for(postid))
    end

    def find(postid)
      load(@locator.path_for(postid))
    end

    def recent(limit)
      all.max_by(limit, &:creation)
    end

    def set_tags(postid, tags)
      revise(postid) { |content| content.with(tags:) }
    end

    # :reek:LongParameterList
    def update(postid, title:, body:, tags:)
      revise(postid) { |content| content.with(title:, body:, tags:) }
    end

    private

    def load(path)
      @serializer.load(path, @locator.postid_for(path))
    end

    def persist(postid, content)
      @serializer.write(@locator.path_for(postid), content)
    end

    def revise(postid)
      content = PostContent.editing(find(postid), updated: Time.now.utc)
      persist(postid, yield(content))
    end
  end
end
