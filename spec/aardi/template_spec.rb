# frozen_string_literal: true

require 'spec_helper'

class TemplateSpec < Minitest::Spec
  describe Aardi::Template do
    before do
      setup_config
      make_renderer
    end

    subject do
      Aardi::Template.new(sample_path('minimal_template.html'))
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
        src = Aardi::PageContent.new('Body.', 'Title', Aardi::Metadata.new("Description: A short desc\n"))
        html = subject.render(src)

        _(html).must_include 'content="A short desc"'
      end

      it 'leaves the meta description unchanged when no Description metadata' do
        src = Aardi::PageContent.new('Body.', 'Title')
        html = subject.render(src)

        _(html).must_include 'name="description"'
      end

      it 'HTML-escapes the page title' do
        src = Aardi::PageContent.new('Body.', '<script>alert(1)</script>')
        html = subject.render(src)

        _(html).wont_include '<script>alert(1)</script>'
        _(html).must_include '&lt;script&gt;alert(1)&lt;/script&gt;'
      end

      it 'HTML-escapes the meta description content' do
        src = Aardi::PageContent.new('Body.', 'Title',
                                     Aardi::Metadata.new(%(Description: A "quoted" & <tagged> desc\n)))
        html = subject.render(src)

        _(html).must_include 'A &quot;quoted&quot; &amp; <tagged> desc'
      end
    end

    describe '.new' do
      it 'raises a named error when the template has no main element' do
        Tempfile.create(['tpl', '.html']) do |file|
          file.write('<!DOCTYPE html><html><head><title></title>' \
                     '<meta name="description" content=""></head><body></body></html>')
          file.flush
          err = _(-> { Aardi::Template.new(file.path) })
                .must_raise Aardi::MissingTemplateElementError
          _(err.message).must_match(/Template missing required <main> element/)
          _(err.message).must_include file.path
        end
      end

      it 'raises a named error when the template has no title element' do
        Tempfile.create(['tpl', '.html']) do |file|
          file.write('<!DOCTYPE html><html><head>' \
                     '<meta name="description" content=""></head><body><main></main></body></html>')
          file.flush
          err = _(-> { Aardi::Template.new(file.path) })
                .must_raise Aardi::MissingTemplateElementError
          _(err.message).must_match(/Template missing required <title> element/)
          _(err.message).must_include file.path
        end
      end
    end
  end
end
