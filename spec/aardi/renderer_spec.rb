# frozen_string_literal: true

require 'spec_helper'

class RendererSpec < Minitest::Spec
  describe Aardi::Renderer do
    before do
      @ledger = setup_ledger(config: setup_config)
    end

    subject do
      @ledger[:renderer]
    end

    describe '#markdown' do
      it 'returns HTML for a markdown heading' do
        html = subject.markdown('## Hello')

        _(html).must_include '<h2'
        _(html).must_include 'Hello'
      end

      it 'returns HTML for a markdown paragraph' do
        html = subject.markdown('Just a paragraph.')

        _(html).must_include '<p>'
        _(html).must_include 'Just a paragraph'
      end

      it 'resets custom_renderer state between calls so heading ids do not collide' do
        subject.markdown('## Hello')
        second = subject.markdown('## Hello')

        _(second).must_include 'id="hello"'
        _(second).wont_include 'id="hello-1"'
      end

      it 'returns identical output for identical input across calls' do
        first = subject.markdown('## Hello')
        second = subject.markdown('## Hello')

        _(second).must_equal first
      end
    end
  end
end
