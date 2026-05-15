# frozen_string_literal: true

require 'spec_helper'

class SitemapSpec < Minitest::Spec
  describe Aardi::Sitemap do
    before do
      setup_config
      setup_ledger
    end

    subject do
      Aardi::Sitemap.new
    end

    describe '#urls' do
      it 'initializes from config sitemap_entries' do
        _(subject.urls).must_include '/'
        _(subject.urls['/'][:loc]).must_include 'http://example.com'
        _(subject.urls['/'][:changefreq]).must_equal 'daily'
      end
    end

    describe '#update_mtime' do
      it 'sets lastmod on the URL entry' do
        time = Time.now
        subject.update_mtime('/', time)

        _(subject.urls['/'][:lastmod]).must_equal time.iso8601
      end
    end

    describe '#record_mtime' do
      it 'sets lastmod when path is tracked' do
        time = Time.now
        subject.record_mtime('/', time)

        _(subject.urls['/'][:lastmod]).must_equal time.iso8601
      end

      it 'is a no-op for an untracked path' do
        subject.record_mtime('/not-in-sitemap/', Time.now)

        _(subject.urls.key?('/not-in-sitemap/')).must_equal false
      end

      it 'is a no-op when path_mtime is nil' do
        subject.record_mtime('/', nil)

        _(subject.urls['/'].key?(:lastmod)).must_equal false
      end
    end

    describe '#target_path' do
      it 'is ./sitemap.xml' do
        _(subject.target_path).must_equal './sitemap.xml'
      end
    end

    describe '#content' do
      it 'produces valid XML with a urlset element' do
        doc = Nokogiri::XML(subject.content)

        _(doc.errors).must_be_empty
        _(doc.at_xpath('//xmlns:urlset',
                       'xmlns' => 'http://www.sitemaps.org/schemas/sitemap/0.9')).wont_be_nil
      end

      it 'includes a loc element for each sitemap entry' do
        doc = Nokogiri::XML(subject.content)
        locs = doc.xpath('//xmlns:loc', 'xmlns' => 'http://www.sitemaps.org/schemas/sitemap/0.9').map(&:text)

        _(locs.any? { |loc| loc.include?('example.com') }).must_equal true
      end

      it 'includes changefreq when present' do
        doc = Nokogiri::XML(subject.content)
        freqs = doc.xpath('//xmlns:changefreq', 'xmlns' => 'http://www.sitemaps.org/schemas/sitemap/0.9')

        _(freqs).wont_be_empty
      end

      it 'includes lastmod when update_mtime has been called' do
        time = Time.now
        subject.update_mtime('/', time)
        doc = Nokogiri::XML(subject.content)
        lastmods = doc.xpath('//xmlns:lastmod', 'xmlns' => 'http://www.sitemaps.org/schemas/sitemap/0.9')

        _(lastmods).wont_be_empty
      end

      describe 'when a configured path is missing on disk' do
        before do
          setup_config(sitemap_entries: { '/missing/' => 'daily' })
          @tmpdir = Dir.mktmpdir
          @original_dir = Dir.pwd
          Dir.chdir(@tmpdir)
        end

        after do
          Dir.chdir(@original_dir)
          FileUtils.rm_rf(@tmpdir)
        end

        it 'prints FATAL and calls exit' do
          sitemap = Aardi::Sitemap.new
          sitemap.define_singleton_method(:exit) { |*| raise SystemExit }

          out, = capture_io do
            assert_raises(SystemExit) { sitemap.content }
          end

          _(out).must_include 'FATAL'
          _(out).must_include '/missing/'
        end
      end
    end

    describe '#render' do
      before do
        @tmpdir = Dir.mktmpdir
        @original_dir = Dir.pwd
        Dir.chdir(@tmpdir)
        File.write(File.join(@tmpdir, 'index.html'), '<html></html>')
        Aardi.ledger[:content_hashes] = Aardi::ContentHashes.new(File.join(@tmpdir, 'hashes.txt'))
      end

      after do
        Dir.chdir(@original_dir)
        FileUtils.rm_rf(@tmpdir)
      end

      it 'writes sitemap.xml in the current directory' do
        capture_io { subject.render }

        _(File.exist?(File.join(@tmpdir, 'sitemap.xml'))).must_equal true
      end

      it 'written sitemap includes the configured site URL' do
        capture_io { subject.render }

        _(File.read(File.join(@tmpdir, 'sitemap.xml'))).must_include 'http://example.com'
      end
    end
  end
end
