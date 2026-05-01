# frozen_string_literal: true

module Aardi
  # :reek:TooManyInstanceVariables
  class Posts
    attr_reader :list, :tag_groups

    def initialize(list, config:, ledger:)
      @config = config
      @ledger = ledger
      @list = list
      build_indexes
    end

    def calendar = @main_calendar

    def calendar_for(tag) = @tag_calendars[tag]

    def list_for(tag) = @tag_groups[tag] || []

    private

    # :reek:TooManyStatements
    def build_indexes
      @tag_groups = {}
      @main_calendar = year_index(@config[:blog_archive_path], tag: nil)
      @tag_calendars = Hash.new { |hash, tag| hash[tag] = year_index(tag_archive_path(tag), tag:) }
      @list.each { |post| index_post(post) }
      clear_default_procs
    end

    def clear_default_procs
      @main_calendar.default_proc = nil
      @tag_calendars.each_value { |cal| cal.default_proc = nil }
      @tag_calendars.default_proc = nil
    end

    # :reek:DuplicateMethodCall
    def index_post(post)
      @main_calendar[post.creation.year] << post
      post.tags&.each do |tag|
        (@tag_groups[tag] ||= []) << post
        @tag_calendars[tag][post.creation.year] << post
      end
    end

    def tag_archive_path(tag)
      blog_archive = @config[:blog_archive_path]
      "#{blog_archive}/#{@config[:blog_tags_path]}/#{tag}/#{blog_archive}"
    end

    def year_index(archive_path, tag:)
      Hash.new do |hash, year|
        hash[year] = Year.new(year, archive_path, config: @config, ledger: @ledger, tag:)
      end
    end
  end
end
