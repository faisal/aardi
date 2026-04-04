# frozen_string_literal: true

require "spec_helper"

class CustomRendererSpec < Minitest::Spec
  describe Aardi::CustomRenderer do
    subject { Aardi::CustomRenderer.new }

    describe "#header" do
      it "generates a header tag with an id derived from the text" do
        result = subject.header("My Header", 2)
        expect(result).must_include 'id="my-header"'
        expect(result).must_include "<h2"
        expect(result).must_include "</h2>"
      end

      it "converts spaces to hyphens in the id" do
        result = subject.header("Hello World", 1)
        expect(result).must_include 'id="hello-world"'
      end

      it "removes special characters from the id" do
        result = subject.header("Hello, World!", 2)
        expect(result).must_include 'id="hello-world"'
      end

      it "appends a counter to duplicate ids" do
        subject.header("Same Title", 2)
        second = subject.header("Same Title", 2)
        expect(second).must_include 'id="same-title-1"'
      end

      it "strips HTML entities from the id" do
        result = subject.header("Hello &amp; World", 2)
        expect(result).must_include 'id="hello-amp-world"'
      end
    end

    describe "#link" do
      it "renders a link with href and content" do
        result = subject.link("http://example.com", nil, "Click")
        expect(result).must_equal '<a href="http://example.com">Click</a>'
      end

      it "includes title attribute when title is given" do
        result = subject.link("http://example.com", "My Title", "Click")
        expect(result).must_include 'title="My Title"'
      end

      it "omits title attribute when title is nil" do
        result = subject.link("http://example.com", nil, "Click")
        expect(result).wont_include "title="
      end
    end

    describe "#reset" do
      it "clears the duplicate id counter" do
        subject.header("Same Title", 2)
        subject.reset
        # After reset, the same title should get the base id again
        result = subject.header("Same Title", 2)
        expect(result).must_include 'id="same-title"'
        expect(result).wont_include 'id="same-title-1"'
      end
    end
  end
end
