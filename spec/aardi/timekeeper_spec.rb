# frozen_string_literal: true

require 'spec_helper'
require 'aardi/timekeeper'

class TimekeeperSpec < Minitest::Spec
  describe Aardi::Timekeeper do
    before do
      @tmpdir = Dir.mktmpdir
      @original_dir = Dir.pwd
      Dir.chdir(@tmpdir)
      init_repo
    end

    after do
      Dir.chdir(@original_dir)
      FileUtils.rm_rf(@tmpdir)
    end

    it 'sets mtime to author_date when they differ' do
      author_date = commit_file('a.txt', 'x', Time.utc(2024, 1, 1, 12, 0, 0))
      FileUtils.touch('a.txt', mtime: author_date + 3600)

      capture_io { Aardi::Timekeeper.new.run }

      _(File.mtime('a.txt')).must_equal author_date
    end

    it 'leaves mtime alone when it already matches author_date' do
      commit_file('b.txt', 'y', Time.utc(2024, 2, 2, 12, 0, 0))
      capture_io { Aardi::Timekeeper.new.run }
      mtime_after_first_pass = File.mtime('b.txt')

      out, = capture_io { Aardi::Timekeeper.new.run }

      _(File.mtime('b.txt')).must_equal mtime_after_first_pass
      _(out).wont_include ' -> '
    end

    it 'prints the mtime transition when updating a file' do
      author_date = commit_file('c.txt', 'z', Time.utc(2024, 3, 3, 12, 0, 0))
      FileUtils.touch('c.txt', mtime: author_date + 3600)

      out, = capture_io { Aardi::Timekeeper.new.run }

      _(out).must_include ' -> '
      _(out).must_include author_date.strftime('%Y-%m-%d')
      _(out).must_include author_date.strftime('%H:%M:%S')
    end

    it 'prints a progress line for every tracked file' do
      commit_file('one.txt', '1', Time.utc(2024, 4, 4, 12, 0, 0))
      commit_file('two.txt', '2', Time.utc(2024, 4, 5, 12, 0, 0))

      out, = capture_io { Aardi::Timekeeper.new.run }

      _(out).must_include '(0 / 2)'
      _(out).must_include '(1 / 2)'
      _(out).must_include 'one.txt'
      _(out).must_include 'two.txt'
    end

    it 'skips files staged but not yet committed' do
      commit_file('committed.txt', 'c', Time.utc(2024, 5, 5, 12, 0, 0))
      File.write('staged.txt', 'pending')
      system('git', 'add', 'staged.txt')
      staged_mtime = Time.utc(2024, 6, 6, 12, 0, 0)
      FileUtils.touch('staged.txt', mtime: staged_mtime)

      capture_io { Aardi::Timekeeper.new.run }

      _(File.mtime('staged.txt')).must_equal staged_mtime
    end

    it 'filters the log by path when a tracked file shares a name with a branch' do
      author_date = commit_file('release', 'r', Time.utc(2024, 8, 8, 12, 0, 0))
      system('git', 'branch', 'release')
      FileUtils.touch('release', mtime: author_date + 3600)

      capture_io { Aardi::Timekeeper.new.run }

      _(File.mtime('release')).must_equal author_date
    end

    it 'iterates files in descending mtime order' do
      commit_file('older.txt', 'o', Time.utc(2024, 7, 1, 12, 0, 0))
      commit_file('newer.txt', 'n', Time.utc(2024, 7, 2, 12, 0, 0))
      FileUtils.touch('older.txt', mtime: Time.utc(2020, 1, 1))
      FileUtils.touch('newer.txt', mtime: Time.utc(2030, 1, 1))

      out, = capture_io { Aardi::Timekeeper.new.run }

      _(out.index('newer.txt')).must_be :<, out.index('older.txt')
    end
  end

  private

  # :reek:TooManyStatements
  def commit_file(path, content, author_date)
    File.write(path, content)
    system('git', 'add', path)
    iso = author_date.utc.iso8601
    env = { 'GIT_AUTHOR_DATE' => iso, 'GIT_COMMITTER_DATE' => iso }
    system(env, 'git', 'commit', '-q', '-m', "add #{path}", '--date', iso)
    author_date
  end

  def init_repo
    system('git', 'init', '-q', '-b', 'main')
    system('git', 'config', 'user.email', 'test@example.com')
    system('git', 'config', 'user.name', 'Test User')
  end
end
