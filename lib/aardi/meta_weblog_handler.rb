# frozen_string_literal: true

require 'aardi'
require 'aardi/post_store'
require 'aardi/media_store'
require 'aardi/meta_weblog_post_mapper'
require 'aardi/meta_weblog_categories'

module Aardi
  # The MetaWeblog / MovableType / Blogger XML-RPC method surface that MarsEdit
  # talks to. Credentials are ignored (open on localhost); post struct mapping
  # and tag<->category mapping are delegated to collaborators; on_change is
  # invoked after every mutation so the static site can be regenerated. Methods
  # are snake_case here and wired to their dotted XML-RPC names in tasks/api.rake.
  # :reek:TooManyMethods
  # :reek:TooManyInstanceVariables
  class MetaWeblogHandler
    SUPPORTED_METHODS = %w[
      metaWeblog.newPost metaWeblog.editPost metaWeblog.getPost
      metaWeblog.getRecentPosts metaWeblog.getCategories metaWeblog.newMediaObject
      blogger.getUsersBlogs blogger.deletePost
      mt.getCategoryList mt.getPostCategories mt.setPostCategories mt.supportedMethods
    ].freeze

    # :reek:LongParameterList
    def initialize(store:, media:, on_change:,
                   mapper: MetaWeblogPostMapper.new, categories: MetaWeblogCategories.new)
      @store = store
      @media = media
      @on_change = on_change
      @mapper = mapper
      @categories = categories
    end

    def categories
      @categories.list(@store.all)
    end

    def delete_post(postid)
      @store.delete(postid)
      changed
    end

    def edit_post(postid, struct, _publish)
      @store.update(postid, **@mapper.fields(struct))
      changed
    end

    def get_post(postid)
      @mapper.to_struct(@store.find(postid))
    end

    def new_media_object(struct)
      @media.save(**@mapper.media(struct))
    end

    def new_post(struct, _publish)
      postid = @store.create(**@mapper.new_fields(struct))
      @on_change.call
      postid
    end

    def post_categories(postid)
      @categories.assigned(@store.find(postid).tags)
    end

    def recent_posts(limit)
      @mapper.to_structs(@store.recent(limit))
    end

    def set_post_categories(postid, categories)
      @store.set_tags(postid, @categories.names(categories))
      changed
    end

    def supported_methods
      SUPPORTED_METHODS
    end

    def users_blogs
      url = Config[:site_url]
      [{ 'blogid' => url, 'blogName' => Config[:site_title], 'url' => url }]
    end

    private

    # Re-renders the static site and reports XML-RPC boolean success, so this is
    # not a predicate.
    def changed # rubocop:disable Naming/PredicateMethod
      @on_change.call
      true
    end
  end
end
