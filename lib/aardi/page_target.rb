# frozen_string_literal: true

module Aardi
  class PageTarget < FileTarget
    private

    # Optimization: in PageTarget first check the existing .html
    # list rather than always rechecking the file system. But then
    # check anyway because html_files doesn't always catch tag pages.
    def file_exists?
      @html_files.include?(@path) || File.exist?(@path)
    end
  end
end
