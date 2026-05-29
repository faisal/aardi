# frozen_string_literal: true

require 'aardi'
require 'aardi/meta_weblog_categories'

module Aardi
  # Translates between MarsEdit/MetaWeblog structs and the values PostStore and
  # MediaStore understand. Category/tag translation is delegated to
  # MetaWeblogCategories.
  class MetaWeblogPostMapper
    def initialize(categories: MetaWeblogCategories.new)
      @categories = categories
    end

    # :reek:FeatureEnvy
    def fields(struct)
      { title: struct['title'].to_s, body: struct['description'].to_s,
        tags: @categories.from_struct(struct) }
    end

    def media(struct)
      { name: struct['name'], bytes: struct['bits'] }
    end

    def new_fields(struct)
      fields(struct).merge(creation: created_at(struct))
    end

    # :reek:FeatureEnvy
    def to_struct(record)
      url = record.url
      tags = record.tags
      { 'postid' => record.postid, 'title' => record.title.to_s,
        'description' => record.body, 'dateCreated' => record.creation,
        'link' => url, 'permaLink' => url,
        'categories' => tags, 'mt_keywords' => tags.join(', ') }
    end

    def to_structs(records)
      records.map { |record| to_struct(record) }
    end

    private

    # :reek:ManualDispatch
    def created_at(struct)
      value = struct['dateCreated']
      return Time.now.utc unless value

      value.respond_to?(:to_time) ? value.to_time.utc : value
    end
  end
end
