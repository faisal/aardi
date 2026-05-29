# frozen_string_literal: true

require 'aardi'
require 'aardi/post_record'

module Aardi
  # Knows the on-disk post format: YAML frontmatter, a "\n----\n" separator,
  # then the raw Markdown body. Dumps PostContent and loads PostRecord.
  class PostSerializer
    SEPARATOR = "\n----\n"

    # :reek:FeatureEnvy
    def dump(content)
      tags = content.tags
      fields = { 'Title' => content.title, 'Creation' => content.creation,
                 'Updated' => content.updated, 'Tags' => (tags.join(' ') unless tags.empty?) }.compact
      "#{fields.to_yaml.delete_prefix("---\n")}----\n#{content.body}"
    end

    def load(path, postid)
      post = Post.new(path)
      body = File.read(path).rpartition(SEPARATOR).last
      PostRecord.new(postid:, title: post.title, body:, creation: post.creation,
                     updated: post.updated, tags: post.tags || [], url: post.url)
    end

    def write(path, content)
      FileUtils.mkdir_p(File.dirname(path))
      File.write(path, dump(content))
    end
  end
end
