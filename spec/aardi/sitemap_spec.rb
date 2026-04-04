# frozen_string_literal: true

require "spec_helper"

class SitemapSpec < Minitest::Spec
  describe Aardi::Sitemap do
    before { setup_config }

    subject { Aardi::Sitemap.new }

    describe "#urls" do
      it "initializes from config sitemap_entries" do
        expect(subject.urls).must_include "/"
        expect(subject.urls["/"][:loc]).must_include "http://example.com"
        expect(subject.urls["/"][:changefreq]).must_equal "daily"
      end
    end

    describe "#update_mtime" do
      it "sets lastmod on the URL entry" do
        time = Time.utc(2024, 6, 1, 12, 0, 0)
        subject.update_mtime("/", time)
        expect(subject.urls["/"][:lastmod]).must_equal time.iso8601
      end
    end

    describe "#target_path" do
      it "is ./sitemap.xml" do
        expect(subject.target_path).must_equal "./sitemap.xml"
      end
    end

    describe "#content" do
      it "produces valid XML with a urlset element" do
        doc = Nokogiri::XML(subject.content)
        expect(doc.errors).must_be_empty
        expect(doc.at_xpath("//xmlns:urlset",
          "xmlns" => "http://www.sitemaps.org/schemas/sitemap/0.9")).wont_be_nil
      end

      it "includes a loc element for each sitemap entry" do
        doc = Nokogiri::XML(subject.content)
        locs = doc.xpath("//xmlns:loc", "xmlns" => "http://www.sitemaps.org/schemas/sitemap/0.9").map(&:text)
        expect(locs.any? { |loc| loc.include?("example.com") }).must_equal true
      end

      it "includes changefreq when present" do
        doc = Nokogiri::XML(subject.content)
        freqs = doc.xpath("//xmlns:changefreq", "xmlns" => "http://www.sitemaps.org/schemas/sitemap/0.9")
        expect(freqs).wont_be_empty
      end

      it "includes lastmod when update_mtime has been called" do
        time = Time.utc(2024, 6, 1)
        subject.update_mtime("/", time)
        doc = Nokogiri::XML(subject.content)
        lastmods = doc.xpath("//xmlns:lastmod", "xmlns" => "http://www.sitemaps.org/schemas/sitemap/0.9")
        expect(lastmods).wont_be_empty
      end
    end
  end
end
