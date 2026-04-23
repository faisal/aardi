# frozen_string_literal: true

require 'spec_helper'

class SitemapSpec < Minitest::Spec
  describe Aardi::Sitemap do
    before do
      setup_config
      setup_ledger
      @config = Aardi.config
      @ledger = Aardi.ledger
    end

    subject do
      Aardi::Sitemap.new(config: @config, ledger: @ledger)
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
    end
  end
end
