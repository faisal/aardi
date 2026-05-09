# frozen_string_literal: true

require 'spec_helper'

class TemplateSpec < Minitest::Spec
  describe Aardi::Template do
    before do
      setup_config
      setup_ledger
    end

    subject do
      Aardi.ledger[:template]
    end

    describe '#render' do
      it 'inserts rendered markup into the main element' do
        src = Aardi::PageContent.new("## Hello\n\nWorld.", 'Hello')
        html = subject.render(src)

        _(html).must_include '<h2'
        _(html).must_include 'Hello'
      end

      it 'appends the page title to the title tag' do
        src = Aardi::PageContent.new('Body.', 'My Page Title')
        html = subject.render(src)

        _(html).must_include 'My Page Title'
        _(html).must_match(%r{<title>.*My Page Title.*</title>}m)
      end

      it 'sets the meta description when metadata contains Description' do
        src = Aardi::PageContent.new('Body.', 'Title', { 'Description' => 'A short desc' })
        html = subject.render(src)

        _(html).must_include 'content="A short desc"'
      end

      it 'leaves the meta description unchanged when no Description metadata' do
        src = Aardi::PageContent.new('Body.', 'Title')
        html = subject.render(src)

        _(html).must_include 'name="description"'
      end
    end
  end
end
