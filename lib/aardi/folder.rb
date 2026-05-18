# frozen_string_literal: true

module Aardi
  class Folder
    def initialize(path)
      @path = path
      @normalized_path = "#{path.sub(/^\./, '')}/"
    end

    def mtime = children.filter_map(&:mtime).max

    def render(renderer)
      result = children.each_with_object({}) { |child, acc| acc.merge!(child.render(renderer)) }
      renderer.sitemap.record_mtime(@normalized_path, mtime) unless @path == '.'
      result
    end

    private

    def children
      sources + folders
    end

    def folders
      @folders ||= paths.filter_map { |path| Folder.new(path) if File.directory?(path) }
    end

    def paths
      @paths ||= FileList["#{@path}/*"].exclude(Aardi.config[:files_to_exclude])
    end

    def sources
      @sources ||= paths.filter_map { |path| Page.new(path) if path.end_with?('.md') }
    end
  end
end
