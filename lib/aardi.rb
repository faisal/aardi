# frozen_string_literal: true

%w[
  date
  fileutils
  json
  yaml
  zlib
  nokogiri
  rake
  redcarpet
].each { |lib| require lib }

%w[
  errors
  version
  config
  metadata
  content
  content_hashes
  custom_renderer
  renderer
  abstract_blog
  abstract_page_support
  abstract_feed
  file_target
  page_target
  page_content
  template
  page
  post_bookmark_line
  post
  day
  month
  year
  archive
  home_footer_links
  home
  tags
  atom_feed
  json_feed
  blog
  tag_blog
  folder
  sitemap
  orphanage
  site
].each { |name| require_relative "aardi/#{name}" }

module Aardi
  class << self
    # :reek:Attribute
    attr_writer :renderer

    def renderer = @renderer ||= Renderer.new

    def reset!
      Config.reset
      @renderer = nil
    end
  end
end
