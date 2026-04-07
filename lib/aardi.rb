# frozen_string_literal: true

require "date"
require "fileutils"
require "json"
require "yaml"
require "zlib"

require "nokogiri"
require "rake"
require "redcarpet"

require_relative "aardi/version"
require_relative "aardi/config"
require_relative "aardi/ledger"
require_relative "aardi/content"
require_relative "aardi/content_hashes"
require_relative "aardi/custom_renderer"
require_relative "aardi/abstract_blog"
require_relative "aardi/abstract_page_support"
require_relative "aardi/abstract_feed"
require_relative "aardi/file_target"
require_relative "aardi/page_target"
require_relative "aardi/page_content"
require_relative "aardi/template"
require_relative "aardi/page"
require_relative "aardi/post"
require_relative "aardi/day"
require_relative "aardi/month"
require_relative "aardi/year"
require_relative "aardi/archive"
require_relative "aardi/home"
require_relative "aardi/atom_feed"
require_relative "aardi/json_feed"
require_relative "aardi/blog"
require_relative "aardi/folder"
require_relative "aardi/sitemap"
require_relative "aardi/orphanage"
require_relative "aardi/site"

RubyVM::YJIT.enable if RUBY_ENGINE == "ruby"

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
