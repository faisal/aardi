# frozen_string_literal: true

require 'spec_helper'

class RendererSpec < Minitest::Spec
  describe Aardi::Renderer do
    before do
      setup_config
      setup_ledger
    end

    subject do
      Aardi.ledger[:renderer]
    end

    describe '.new' do
      it 'reads markup_options from Aardi.config' do
        renderer = Aardi::Renderer.new

        _(renderer.markup('## Hello')).must_include '<h2'
      end

      it 'does not crash when config has no :markup_options' do
        setup_config(markup_options: nil)

        _(Aardi::Renderer.new).must_be_instance_of Aardi::Renderer
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

    describe '#markup_snippet' do
      it 'strips the content' do
        content = "### Header

Snippet content
"

        marked_up = subject.markup_snippet(content)
        _(marked_up).must_equal marked_up.strip
      end
    end
  end
end
