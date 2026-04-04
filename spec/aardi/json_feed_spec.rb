# frozen_string_literal: true

require "spec_helper"

class JSONFeedSpec < Minitest::Spec
  describe Aardi::JSONFeed do
    before { setup_config }

    def make_feed(posts = [])
      Aardi::JSONFeed.new(posts)
    end

    describe "#target_path" do
      it "is ./index.json" do
        expect(make_feed.target_path).must_equal "./index.json"
      end
    end

    describe "#content" do
      def parsed(posts = [StubPost.new(Time.utc(2024, 1, 15))])
        JSON.parse(make_feed(posts).content)
      end

      it "produces valid JSON" do
        expect(proc { parsed }).must_be_silent
      end

      it "uses JSON Feed version 1.1" do
        expect(parsed["version"]).must_equal "https://jsonfeed.org/version/1.1"
      end

      it "includes the site title" do
        expect(parsed["title"]).must_equal "Test Site"
      end

      it "includes the home_page_url" do
        expect(parsed["home_page_url"]).must_equal "http://example.com"
      end

      it "includes the feed_url pointing to index.json" do
        expect(parsed["feed_url"]).must_equal "http://example.com/index.json"
      end

      it "includes an item for each post" do
        posts = [
          StubPost.new(Time.utc(2024, 1, 15), title: "Alpha"),
          StubPost.new(Time.utc(2024, 2, 10), title: "Beta")
        ]
        items = parsed(posts)["items"]
        titles = items.map { |item| item["title"] }
        expect(titles).must_include "Alpha"
        expect(titles).must_include "Beta"
      end

      it "item includes required fields: id, url, title, date_published, content_html" do
        item = parsed.dig("items", 0)
        %w[id url title date_published content_html].each do |field|
          expect(item.key?(field)).must_equal true, "expected item to have field #{field}"
        end
      end

      it "omits date_modified when creation equals updated" do
        post = StubPost.new(Time.utc(2024, 1, 15))
        item = parsed([post]).dig("items", 0)
        expect(item.key?("date_modified")).must_equal false
      end

      it "includes date_modified when updated differs from creation" do
        post = StubPost.new(Time.utc(2024, 1, 15))
        def post.updated = Time.utc(2024, 2, 1)
        item = parsed([post]).dig("items", 0)
        expect(item.key?("date_modified")).must_equal true
      end
    end
  end
end
