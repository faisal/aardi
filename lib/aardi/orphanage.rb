# frozen_string_literal: true

module Aardi
  class Orphanage
    def report(html_files, generated_paths)
      (html_files - generated_paths).each { |path| warn("Orphan: #{path}") unless ignored?(path) }
    end

    private

    def ignored?(path)
      Array(Aardi.config[:ignore_orphans]).any? { |prefix| path.start_with?(prefix) }
    end
  end
end
