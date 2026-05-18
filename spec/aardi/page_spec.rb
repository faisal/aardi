# frozen_string_literal: true

require 'spec_helper'

class PageSpec < Minitest::Spec
  describe Aardi::Page do
    before do
      setup_config
      @renderer = make_renderer
      @tmpdir = Dir.mktmpdir
    end

    after do
      FileUtils.rm_rf(@tmpdir)
    end

    def make_page(name: 'about', body: "# About\n\nBody text.\n", yaml: 'Title: About')
      page_path = File.join(@tmpdir, "#{name}.md")
      File.write(page_path, "#{yaml}\n\n----\n#{body}")
      Aardi::Page.new(page_path)
    end

    describe '#target_path' do
      it 'replaces the source extension with .html' do
        page = make_page(name: 'about')

        _(page.target_path).must_equal File.join(@tmpdir, 'about.html')
      end
    end

    describe '#render' do
      it 'writes an HTML file at the target path' do
        page = make_page

        capture_io { page.render(@renderer) }

        _(File.exist?(page.target_path)).must_equal true
      end

      it 'rendered output includes the source body text' do
        page = make_page(body: "# About\n\nUnique body content.\n")

        capture_io { page.render(@renderer) }

        _(File.read(page.target_path)).must_include 'Unique body content'
      end

      it 'rendered output includes the page title in the HTML title tag' do
        page = make_page(yaml: 'Title: Specific Title', body: "# Heading\n\nText.\n")

        capture_io { page.render(@renderer) }

        _(File.read(page.target_path)).must_match(%r{<title>[^<]*Specific Title[^<]*</title>}m)
      end
    end
  end
end
