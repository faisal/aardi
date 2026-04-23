# frozen_string_literal: true

module Aardi
  class Folder
    def initialize(path, config:, ledger:)
      @path = path
      @config = config
      @ledger = ledger
      @normalized_path = "#{path.sub(/^\./, '')}/"
    end

    def mtime = children.max_by(&:mtime)&.mtime

    def render
      children.each(&:render)

      update_sitemap if @config[:sitemap_entries][@normalized_path]
    end

    private

    def children
      sources + folders
    end

    def folders
      @folders ||= paths.filter_map do |path|
        Folder.new(path, config: @config, ledger: @ledger) if File.directory?(path)
      end
    end

    def paths
      @paths ||= FileList["#{@path}/*"].exclude(@config[:files_to_exclude])
    end

    def sources
      @sources ||= paths.filter_map { |path| Page.new(path, ledger: @ledger) if path.end_with?('.md') }
    end

    def update_sitemap
      # '.' is the top level so skip it since the homepage will register itself
      @ledger[:sitemap].update_mtime(@normalized_path, mtime) unless @path == '.'
    end
  end
end
