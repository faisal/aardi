# frozen_string_literal: true

require "spec_helper"

class PostSpec < Minitest::Spec
  describe Aardi::Post do
    before do
      setup_config
      setup_ledger
      @tmpdir = Dir.mktmpdir
    end

    after { FileUtils.rm_rf(@tmpdir) }

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
        expect(post.creation).must_be_kind_of Time
        expect(post.creation.year).must_equal 2024
        expect(post.creation.month).must_equal 3
        expect(post.creation.day).must_equal 10
      end
    end

    describe "#year / #month / #day" do
      it "delegates to the creation date components" do
        post = make_post(creation: Time.utc(2024, 6, 20, 0, 0, 0))
        expect(post.year).must_equal 2024
        expect(post.month).must_equal 6
        expect(post.day).must_equal 20
      end
    end

    describe "#name" do
      it "returns the filename without extension" do
        post = make_post(name: "cool-post")
        expect(post.name).must_equal "cool-post"
      end
    end

    describe "#url" do
      it "builds the URL from site_url, archive_path, date, and name" do
        post = make_post(creation: Time.utc(2024, 1, 5, 0, 0, 0), name: "my-post")
        expect(post.url).must_equal "http://example.com/blog/2024/01/05/my-post"
      end
    end

    describe "#target_path" do
      it "uses the archive path and creation date" do
        post = make_post(creation: Time.utc(2024, 1, 5, 0, 0, 0), name: "my-post")
        expect(post.target_path).must_equal "./blog/2024/01/05/my-post.html"
      end
    end

    describe "#updated" do
      it "returns creation when no Updated metadata" do
        post = make_post(creation: Time.utc(2024, 1, 15, 0, 0, 0))
        expect(post.updated).must_equal post.creation
      end

      it "returns the Updated metadata value when present" do
        post = make_post(creation: Time.utc(2024, 1, 15, 0, 0, 0),
          extra_yaml: "Updated: 2024-02-01T00:00:00Z")
        expect(post.updated.year).must_equal 2024
        expect(post.updated.month).must_equal 2
      end
    end

    describe "#content" do
      it "includes the source content" do
        post = make_post(title: "My Post")
        expect(post.content).must_include "Body text."
      end

      it "appends a bookmark link pointing to the post URL" do
        post = make_post(name: "bookmarked-post", creation: Time.utc(2024, 1, 15, 0, 0, 0))
        expect(post.content).must_include 'class="bookmark"'
        expect(post.content).must_include post.url
      end
    end

    describe "#feed_snippet" do
      it "returns rendered HTML of the content without the title heading" do
        post = make_post(title: "My Post")
        snippet = post.feed_snippet
        expect(snippet).must_include "<p>"
        expect(snippet).wont_match(/^### My Post/)
      end
    end

    describe "#title" do
      it "extracts the title from the first markdown heading" do
        post = make_post(title: "Heading Title")
        expect(post.title).must_equal "Heading Title"
      end
    end
  end
end
