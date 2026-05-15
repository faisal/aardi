# frozen_string_literal: true

require 'spec_helper'
require 'rake'

class InitRakeSpec < Minitest::Spec
  describe 'rake init' do
    before do
      @tmpdir = Dir.mktmpdir
      @original_dir = Dir.pwd
      Dir.chdir(@tmpdir)
      Rake.application = Rake::Application.new
      Object.send(:remove_const, :INIT_FILES_DIR) if Object.const_defined?(:INIT_FILES_DIR)
      Object.send(:remove_const, :InitTask) if Object.const_defined?(:InitTask)
      load File.expand_path('../../lib/aardi/tasks/init.rake', __dir__)
    end

    after do
      Dir.chdir(@original_dir)
      FileUtils.rm_rf(@tmpdir)
    end

    it 'creates config.yml in the current directory' do
      capture_io { Rake.application[:init].invoke }

      _(File.exist?('config.yml')).must_equal true
    end

    it 'creates .template.html in the current directory' do
      capture_io { Rake.application[:init].invoke }

      _(File.exist?('.template.html')).must_equal true
    end

    it 'prints a message confirming scaffolding was installed' do
      out, = capture_io { Rake.application[:init].invoke }

      _(out).must_include 'scaffolding installed'
    end

    it "prints 'Wrote' for each new file" do
      out, = capture_io { Rake.application[:init].invoke }

      _(out).must_include 'Wrote'
    end

    it 'does not overwrite existing files without prompting' do
      File.write('config.yml', "original: content\n")
      original_stdin = $stdin
      $stdin = StringIO.new("n\n")
      begin
        out, = capture_io { Rake.application[:init].invoke }
      ensure
        $stdin = original_stdin
      end

      _(out).must_include 'Skipped'
      _(File.read('config.yml')).must_include 'original: content'
    end

    it 'overwrites an existing file when the prompt is answered with y' do
      File.write('config.yml', "original: content\n")
      original_stdin = $stdin
      $stdin = StringIO.new("y\n")
      begin
        out, = capture_io { Rake.application[:init].invoke }
      ensure
        $stdin = original_stdin
      end

      _(out).must_include 'Wrote'
      _(File.read('config.yml')).wont_include 'original: content'
    end

    it 'reprompts when input is neither y nor n' do
      File.write('config.yml', "original: content\n")
      original_stdin = $stdin
      $stdin = StringIO.new("maybe\nn\n")
      begin
        out, = capture_io { Rake.application[:init].invoke }
      ensure
        $stdin = original_stdin
      end

      _(out).must_include 'Skipped'
    end
  end
end
