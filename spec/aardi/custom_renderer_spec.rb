# frozen_string_literal: true

require "spec_helper"

class CustomRendererSpec < Minitest::Spec
  describe Aardi::CustomRenderer do
    subject do
      Aardi::CustomRenderer.new
    end

    describe "#header" do
      it "generates a header tag with an id derived from the text" do
        result = subject.header("My Header", 2)

        _(result).must_include 'id="my-header"'
        _(result).must_include "<h2"
        _(result).must_include "</h2>"
      end

      it "converts spaces to hyphens in the id" do
        result = subject.header("Hello World", 1)

        _(result).must_include 'id="hello-world"'
      end

      it "removes special characters from the id" do
        result = subject.header("Hello, World!", 2)

        _(result).must_include 'id="hello-world"'
      end

      it "appends a counter to duplicate ids" do
        subject.header("Same Title", 2)
        second = subject.header("Same Title", 2)

        _(second).must_include 'id="same-title-1"'
      end

      it "strips HTML entities from the id" do
        result = subject.header("Hello &amp; World", 2)

        _(result).must_include 'id="hello-amp-world"'
      end
    end

    describe "#link" do
      it "renders a link with href and content" do
        result = subject.link("http://example.com", nil, "Click")

        _(result).must_equal '<a href="http://example.com">Click</a>'
      end

      it "includes title attribute when title is given" do
        result = subject.link("http://example.com", "My Title", "Click")

        _(result).must_include 'title="My Title"'
      end

      it "omits title attribute when title is nil" do
        result = subject.link("http://example.com", nil, "Click")

        _(result).wont_include "title="
      end
    end

    describe "#reset" do
      it "clears the duplicate id counter" do
        subject.header("Same Title", 2)
        subject.reset
        result = subject.header("Same Title", 2)

        _(result).must_include 'id="same-title"'
        _(result).wont_include 'id="same-title-1"'
      end
    end
  end
end
