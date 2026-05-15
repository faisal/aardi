# frozen_string_literal: true

require 'spec_helper'

class SiteSpec < Minitest::Spec
  describe Aardi::Site do
    before do
      setup_config(template_path: File.join(SpecHelpers::SAMPLES_DIR, 'minimal_template.html'),
                   blog_posts_path: File.join(SpecHelpers::SAMPLES_DIR, 'nonexistent_posts'),
                   content_hashes_path: '/nonexistent_test_hashes')
    end

    describe '#initialize' do
      it 'constructs without arguments' do
        _(Aardi::Site.new).must_be_kind_of Aardi::Site
      end
    end

    describe '#blog' do
      it 'returns a Blog instance' do
        _(Aardi::Site.new.blog).must_be_kind_of Aardi::Blog
      end

      it 'memoizes the same Blog instance' do
        site = Aardi::Site.new

        _(site.blog).must_be_same_as site.blog
      end
    end

    describe 'with a populated posts directory' do
      # :reek:TooManyStatements
      before do
        @tmpdir = Dir.mktmpdir
        @original_dir = Dir.pwd
        FileUtils.mkdir_p(File.join(@tmpdir, 'posts'))
        File.write(File.join(@tmpdir, 'posts', 'first.md'),
                   "Creation: 2024-01-15T12:00:00Z\n\n----\n### First Post\n\nHello.\n")
        File.write(File.join(@tmpdir, 'posts', 'second.md'),
                   "Creation: 2024-02-20T08:00:00Z\n\n----\n### Second Post\n\nWorld.\n")
        Dir.chdir(@tmpdir)
        setup_config(template_path: File.join(SpecHelpers::SAMPLES_DIR, 'minimal_template.html'),
                     blog_posts_path: './posts',
                     content_hashes_path: File.join(@tmpdir, 'hashes.txt'))
      end

      after do
        Dir.chdir(@original_dir)
        FileUtils.rm_rf(@tmpdir)
      end

      describe '#initialize' do
        it 'loads each markup post into the blog' do
          site = Aardi::Site.new

          _(site.blog.instance_variable_get(:@posts).length).must_equal 2
        end
      end

      describe '#children (private)' do
        it 'includes a Folder, the Blog, and the Sitemap' do
          site = Aardi::Site.new
          children_classes = site.send(:children).map(&:class)

          _(children_classes).must_include Aardi::Folder
          _(children_classes).must_include Aardi::Blog
          _(children_classes).must_include Aardi::Sitemap
        end
      end

      describe '#render' do
        it 'writes the home page' do
          capture_io { Aardi::Site.new.render }

          _(File.exist?(File.join(@tmpdir, 'index.html'))).must_equal true
        end

        it 'writes the sitemap' do
          capture_io { Aardi::Site.new.render }

          _(File.exist?(File.join(@tmpdir, 'sitemap.xml'))).must_equal true
        end

        it 'writes the blog archive index' do
          capture_io { Aardi::Site.new.render }

          _(File.exist?(File.join(@tmpdir, 'blog', 'index.html'))).must_equal true
        end

        it 'writes the content_hashes ledger to disk' do
          capture_io { Aardi::Site.new.render }

          _(File.exist?(File.join(@tmpdir, 'hashes.txt'))).must_equal true
        end
      end
    end
  end
end
