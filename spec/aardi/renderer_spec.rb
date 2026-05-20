# frozen_string_literal: true

require 'spec_helper'

class RendererSpec < Minitest::Spec
  describe Aardi::Renderer do
    before do
      setup_config
      make_renderer
    end

    subject { Aardi.renderer }

    describe '.new' do
      it 'reads markup_options from Aardi::Config' do
        _(make_renderer.markup('## Hello')).must_include '<h2'
      end

      it 'does not crash when :markup_options is present with a nil value' do
        setup_config(markup_options: nil)

        _(make_renderer).must_be_instance_of Aardi::Renderer
      end

      it 'does not crash when :markup_options is absent from config' do
        setup_config(markup_options: SpecHelpers::OMIT)

        _(make_renderer).must_be_instance_of Aardi::Renderer
      end

      it 'passes markup_options to Redcarpet with symbol keys (YAML loads them as strings)' do
        setup_config markup_options: { 'fenced_code_blocks' => true }

        _(make_renderer.markup("```\nx\n```")).must_include '<code>'
      end

      it 'creates its own Template from the configured template_path' do
        src = Aardi::PageContent.new('Body.', 'Title')

        _(Aardi.renderer.render(src)).must_include '<html'
      end
    end

    describe '#render' do
      it 'returns full-page HTML wrapping the rendered markup in the template' do
        src = Aardi::PageContent.new("## Hello\n\nWorld.", 'My Title')
        html = subject.render(src)

        _(html).must_include '<html'
        _(html).must_include '<h2'
        _(html).must_include 'My Title'
      end
    end

    describe '#markup' do
      it 'returns HTML for a markup heading' do
        html = subject.markup('## Hello')

        _(html).must_include '<h2'
        _(html).must_include 'Hello'
      end

      it 'returns HTML for a markup paragraph' do
        html = subject.markup('Just a paragraph.')

        _(html).must_include '<p>'
        _(html).must_include 'Just a paragraph'
      end

      it 'preserves the trailing newline emitted by Redcarpet' do
        _(subject.markup('Just a paragraph.')).must_match(/\n\z/)
      end

      it 'resets custom_renderer state between calls so heading ids do not collide' do
        subject.markup('## Hello')
        second = subject.markup('## Hello')

        _(second).must_include 'id="hello"'
        _(second).wont_include 'id="hello-1"'
      end

      it 'returns identical output for identical input across calls' do
        first = subject.markup('## Hello')
        second = subject.markup('## Hello')

        _(second).must_equal first
      end

      it 'does not strip the output' do
        content = "# Header

Paragraph
"
        marked_up = subject.markup(content)
        _(marked_up).wont_equal marked_up.strip
      end
    end

    describe '#markup_feed_snippet' do
      it 'strips the content' do
        content = "### Header

Snippet content
"

        marked_up = subject.markup_feed_snippet(content)
        _(marked_up).must_equal marked_up.strip
      end
    end
  end
end
