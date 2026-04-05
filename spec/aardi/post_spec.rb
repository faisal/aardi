# frozen_string_literal: true

require "spec_helper"

class PostSpec < Minitest::Spec
  describe Aardi::Post do
    before do
      setup_config
      setup_ledger
      @tmpdir = Dir.mktmpdir
    end

    after do
      FileUtils.rm_rf(@tmpdir)
    end

    # :reek:LongParameterList
    def make_post(creation: Time.utc(2024, 1, 15, 12, 0, 0), title: "My Post", name: "my-post", extra_yaml: "")
      content = "Creation: #{creation.iso8601}\n#{extra_yaml}\n----\n### #{title}\n\nBody text.\n"
      path = File.join(@tmpdir, "#{name}.md")
      File.write(path, content)
      Aardi::Post.new(path)
    end

    describe "#creation" do
      it "returns the Creation value from metadata as a Time" do
        post = make_post(creation: Time.utc(2024, 3, 10, 8, 0, 0))
        _(post.creation).must_be_kind_of Time
        _(post.creation.year).must_equal 2024
        _(post.creation.month).must_equal 3
        _(post.creation.day).must_equal 10
      end
    end

    describe "#year / #month / #day" do
      it "delegates to the creation date components" do
        post = make_post(creation: Time.utc(2024, 6, 20, 0, 0, 0))
        _(post.year).must_equal 2024
        _(post.month).must_equal 6
        _(post.day).must_equal 20
      end
    end

    describe "#name" do
      it "returns the filename without extension" do
        post = make_post(name: "cool-post")
        _(post.name).must_equal "cool-post"
      end
    end

    describe "#url" do
      it "builds the URL from site_url, archive_path, date, and name" do
        post = make_post(creation: Time.utc(2024, 1, 5, 0, 0, 0), name: "my-post")
        _(post.url).must_equal "http://example.com/blog/2024/01/05/my-post"
      end
    end

    describe "#target_path" do
      it "uses the archive path and creation date" do
        post = make_post(creation: Time.utc(2024, 1, 5, 0, 0, 0), name: "my-post")
        _(post.target_path).must_equal "./blog/2024/01/05/my-post.html"
      end
    end

    describe "#updated" do
      it "returns creation when no Updated metadata" do
        post = make_post(creation: Time.utc(2024, 1, 15, 0, 0, 0))
        _(post.updated).must_equal post.creation
      end

      it "returns the Updated metadata value when present" do
        post = make_post(creation: Time.utc(2024, 1, 15, 0, 0, 0),
          extra_yaml: "Updated: 2024-02-01T00:00:00Z")
        _(post.updated.year).must_equal 2024
        _(post.updated.month).must_equal 2
      end
    end

    describe "#content" do
      it "includes the source content" do
        post = make_post(title: "My Post")
        _(post.content).must_include "Body text."
      end

      it "appends a bookmark link pointing to the post URL" do
        post = make_post(name: "bookmarked-post", creation: Time.utc(2024, 1, 15, 0, 0, 0))
        _(post.content).must_include 'class="bookmark"'
        _(post.content).must_include post.url
      end
    end

    describe "#feed_snippet" do
      it "returns rendered HTML of the content without the title heading" do
        post = make_post(title: "My Post")
        snippet = post.feed_snippet
        _(snippet).must_include "<p>"
        _(snippet).wont_match(/^### My Post/)
      end
    end

    describe "#title" do
      it "extracts the title from the first markdown heading" do
        post = make_post(title: "Heading Title")
        _(post.title).must_equal "Heading Title"
      end
    end
  end
end
