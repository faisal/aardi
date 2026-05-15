# frozen_string_literal: true

require 'spec_helper'
require 'rake'

class NewRakeSpec < Minitest::Spec
  describe 'rake new / create_new_post' do
    before do
      setup_config
      @tmpdir = Dir.mktmpdir
      @original_dir = Dir.pwd
      Dir.chdir(@tmpdir)
      FileUtils.mkdir_p('posts')
      if Object.private_method_defined?(:create_new_post) || Object.method_defined?(:create_new_post)
        Object.undef_method(:create_new_post)
      end
      Rake.application = Rake::Application.new
      Rake::Task.define_task(:load_config)
      load File.expand_path('../../lib/aardi/tasks/new.rake', __dir__)
    end

    after do
      Dir.chdir(@original_dir)
      FileUtils.rm_rf(@tmpdir)
    end

    describe '#create_new_post' do
      it 'creates a new markup file under the posts directory' do
        capture_io { create_new_post }
        post_files = Dir.glob('posts/**/*.md')

        _(post_files).wont_be_empty
      end

      it 'prints the path of the created file' do
        out, = capture_io { create_new_post }
        _(out.chomp).must_match(%r{^posts/.+\.md$})
      end

      it 'includes a Creation timestamp in the file content' do
        capture_io { create_new_post }
        content = File.read(Dir.glob('posts/**/*.md').first)

        _(content).must_match(/^Creation: \d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z/)
      end

      it 'uses the ---- separator between YAML and content' do
        capture_io { create_new_post }
        content = File.read(Dir.glob('posts/**/*.md').first)

        _(content).must_include "\n----\n"
      end

      it 'includes a title placeholder in the content' do
        capture_io { create_new_post }
        content = File.read(Dir.glob('posts/**/*.md').first)

        _(content).must_include '### title'
      end
    end

    describe 'rake new task' do
      it 'creates a post file when invoked' do
        capture_io { Rake.application[:new].invoke }

        _(Dir.glob('posts/**/*.md')).wont_be_empty
      end
    end
  end
end
