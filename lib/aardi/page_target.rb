# frozen_string_literal: true

module Aardi
  class PageTarget < FileTarget
    def write
      super
      Aardi.ledger[:html_files].delete(@path)
    end

    private

    def file_exists?
      Aardi.ledger[:html_files].include? @path
    end
  end
end
