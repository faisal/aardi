# frozen_string_literal: true

module Aardi
  class Folder
    def initialize(path)
      @path = path
      @normalized_path = "#{path.sub(/^\./, '')}/"
    end

    def mtime = children.max_by(&:mtime)&.mtime

    def render
      children.each(&:render)

      update_sitemap if Aardi.config[:sitemap_entries][@normalized_path]
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

    def update_sitemap
      # '.' is the top level so skip it since the homepage will register itself
      Aardi.ledger[:sitemap].update_mtime(@normalized_path, mtime) unless @path == '.'
    end
  end
end
