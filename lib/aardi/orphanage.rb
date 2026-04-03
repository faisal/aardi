# frozen_string_literal: true

module Aardi
  class Orphanage
    def warn
      Aardi.ledger[:html_files].each { |path| puts("Orphan: #{path}") unless ignored?(path) }
    end

    private

    def ignored?(path)
      Aardi.config[:ignore_orphans].any? { |prefix| path.start_with?(prefix) }
    end
  end
end
