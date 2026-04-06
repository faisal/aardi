# frozen_string_literal: true

require "spec_helper"

class AtomFeedSpec < Minitest::Spec
  describe Aardi::ATOMFeed do
    before do
      setup_config
    end

    def make_feed(posts = [])
      Aardi::ATOMFeed.new(posts)
    end

    describe "#target_path" do
      it "is ./index.xml" do
        _(make_feed.target_path).must_equal "./index.xml"
      end
    end

    describe "#content" do
      it "produces valid XML" do
        posts = [StubPost.new(Time.utc(2024, 1, 15))]
        doc = Nokogiri::XML(make_feed(posts).content)
        _(doc.errors).must_be_empty
      end

      it "includes the Atom feed namespace" do
        posts = [StubPost.new(Time.utc(2024, 1, 15))]
        content = make_feed(posts).content
        _(content).must_include "http://www.w3.org/2005/Atom"
      end

      it "includes the site title" do
        posts = [StubPost.new(Time.utc(2024, 1, 15))]
        content = make_feed(posts).content
        _(content).must_include "Test Site"
      end

      it "includes the author name" do
        posts = [StubPost.new(Time.utc(2024, 1, 15))]
        content = make_feed(posts).content
        _(content).must_include "Test Author"
      end

      it "includes an entry for each post" do
        posts = [StubPost.new(Time.utc(2024, 1, 15), title: "Post One"), StubPost.new(Time.utc(2024, 2, 10), title: "Post Two")]
        content = make_feed(posts).content
        _(content).must_include "Post One"
        _(content).must_include "Post Two"
      end

      it "includes the feed URL pointing to index.xml" do
        posts = [StubPost.new(Time.utc(2024, 1, 15))]
        content = make_feed(posts).content
        _(content).must_include "http://example.com/index.xml"
      end

      it "includes post titles and URLs in entries" do
        post = StubPost.new(Time.utc(2024, 1, 15), title: "My Entry", name: "my-entry")
        content = make_feed([post]).content
        _(content).must_include "My Entry"
        _(content).must_include post.url
      end
    end
  end
end
