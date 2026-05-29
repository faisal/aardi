# frozen_string_literal: true

module Aardi
  # Read model for a stored post, returned by PostStore queries. A postid is the
  # post file's path relative to the configured posts directory.
  # :reek:DataClump
  PostRecord = Data.define(:postid, :title, :body, :creation, :updated, :tags, :url)
end
