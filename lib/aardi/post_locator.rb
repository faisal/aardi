# frozen_string_literal: true

require 'pathname'
require 'aardi'

module Aardi
  # Translates between postids (paths relative to the posts directory) and
  # absolute file paths, and enumerates the post files on disk.
  class PostLocator
    def all_paths
      Dir.glob(File.join(root, '**', '*.md'))
    end

    def new_postid(creation)
      file = "#{creation.to_i}.md"
      File.join(file.hash.modulo(36).to_s(36), file)
    end

    def path_for(postid)
      File.join(root, postid)
    end

    def postid_for(path)
      Pathname.new(path).relative_path_from(Pathname.new(root)).to_s
    end

    private

    def root
      Config[:blog_posts_path]
    end
  end
end
