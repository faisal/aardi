# frozen_string_literal: true

require 'aardi'

module Aardi
  # Saves media uploaded by MarsEdit (metaWeblog.newMediaObject) under a local
  # directory and reports the URL at which the static server will serve it.
  class MediaStore
    def initialize(dir: 'media')
      @dir = dir
    end

    def save(name:, bytes:)
      filename = File.basename(name)
      FileUtils.mkdir_p(@dir)
      File.binwrite(File.join(@dir, filename), bytes)
      { 'url' => "#{Config[:site_url]}/#{@dir}/#{filename}" }
    end
  end
end
