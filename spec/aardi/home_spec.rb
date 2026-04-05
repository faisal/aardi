# frozen_string_literal: true

require "spec_helper"

class HomeSpec < Minitest::Spec
  describe Aardi::Home do
    before do
      setup_config
    end

    def make_home(posts)
      Aardi::Home.new(posts, "blog")
    end

    describe "#title" do
      it "returns blog_home_title from config" do
        _(make_home([]).title).must_equal "Test Site"
      end
    end

    describe "#target_path" do
      it "is ./index.html" do
        _(make_home([]).target_path).must_equal "./index.html"
      end
    end

    describe "#content" do
      it "includes the site title heading" do
        content = make_home([]).content
        _(content).must_include "# Test Site"
      end

      it "includes footer links to Archive, RSS, and JSON" do
        content = make_home([]).content
        _(content).must_include "Archive"
        _(content).must_include "RSS"
        _(content).must_include "JSON"
      end

      it "groups posts by day with a day heading" do
        posts = [
          StubPost.new(Time.utc(2024, 1, 15, 9, 0), title: "Morning"),
          StubPost.new(Time.utc(2024, 1, 15, 18, 0), title: "Evening")
        ]
        content = make_home(posts).content
        _(content).must_include "## "
        _(content).must_include "Morning"
        _(content).must_include "Evening"
      end

      it "includes posts from different days separately" do
        posts = [
          StubPost.new(Time.utc(2024, 1, 10), title: "Jan 10 Post"),
          StubPost.new(Time.utc(2024, 1, 15), title: "Jan 15 Post")
        ]
        content = make_home(posts).content
        _(content).must_include "Jan 10 Post"
        _(content).must_include "Jan 15 Post"
      end

      it "includes the archive URL in the footer" do
        content = make_home([]).content
        _(content).must_include "http://example.com/blog/"
      end
    end
  end
end
