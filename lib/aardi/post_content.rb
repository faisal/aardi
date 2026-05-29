# frozen_string_literal: true

module Aardi
  # Write model: the fields PostSerializer needs to compose a post file on disk.
  # :reek:DataClump
  PostContent = Data.define(:title, :body, :tags, :creation, :updated) do
    # :reek:FeatureEnvy
    def self.editing(record, updated:)
      new(title: record.title, body: record.body, tags: record.tags,
          creation: record.creation, updated:)
    end

    # :reek:LongParameterList
    def self.fresh(title:, body:, tags:, creation:)
      new(title:, body:, tags:, creation:, updated: nil)
    end
  end
end
