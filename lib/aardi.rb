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
  version
  config
  ledger
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
  home
  tag_index
  atom_feed
  json_feed
  blog
  tag_blog
  blog_tag_pages
  folder
  sitemap
  orphanage
  site
].each { |name| require_relative "aardi/#{name}" }

RubyVM::YJIT.enable if RUBY_ENGINE == 'ruby'

module Aardi
  class << self
    def config = @config ||= Config.new

    def ledger = @ledger ||= Ledger.new

    def reset!
      @config = Config.new
      @ledger = Ledger.new
    end
  end
end
