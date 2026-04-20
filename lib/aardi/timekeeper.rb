# frozen_string_literal: true

require 'git'

module Aardi
  # :reek:TooManyInstanceVariables
  class Timekeeper
    def initialize
      @repo = Git.open(Dir.pwd)
      @commit_log = @repo.log(:all).all
      @files = tracked_files_by_mtime
      @files_count = @files.count
      @updated = 0
      @prior_summary_length = 0
    end

    def run
      @files.each.with_index do |path, index|
        @prior_summary_length = print_progress(index, path)

        commit_date = author_date(path)
        next unless commit_date

        @updated += 1 if fix_mtime?(path, commit_date)
      end
    end

    private

    def author_date(path)
      @commit_log.object(path).execute.first&.author_date
    end

    def fix_mtime?(path, author_date)
      mtime = File.mtime(path)
      return false if author_date == mtime

      FileUtils.touch(path, mtime: author_date)
      puts "\n  #{mtime} -> #{author_date}"
      true
    end

    def print_progress(index, path)
      summary = "(#{index} / #{@files_count}) #{@updated}: #{path}"
      print format("\r%-#{@prior_summary_length}s", summary)
      summary.length
    end

    def tracked_files_by_mtime
      @repo.ls_files.keys.sort_by { |file| File.mtime(file) }.reverse!
    end
  end
end
