# frozen_string_literal: true

require 'spec_helper'

class AardiSpec < Minitest::Spec
  describe Aardi do
    describe '.renderer' do
      it 'returns an Aardi::Renderer instance' do
        setup_config
        make_renderer

        _(Aardi.renderer).must_be_instance_of Aardi::Renderer
      end

      it 'returns the same instance on repeated calls' do
        setup_config
        make_renderer

        _(Aardi.renderer).must_be_same_as Aardi.renderer
      end

      it 'can be replaced by injecting a new renderer' do
        setup_config
        first = make_renderer
        second = make_renderer

        _(Aardi.renderer).must_be_same_as second
        _(Aardi.renderer).wont_be_same_as first
      end
    end

    describe '.reset!' do
      it 'clears config so it can be reloaded' do
        Aardi::Config.load File.join(SpecHelpers::SAMPLES_DIR, 'minimal_config.yml')
        Aardi.reset!

        _(proc { Aardi::Config.load File.join(SpecHelpers::SAMPLES_DIR, 'minimal_config.yml') }).must_be_silent
      end

      it 'clears renderer so the next access creates a fresh instance' do
        setup_config
        before_reset = make_renderer
        setup_config
        make_renderer

        _(Aardi.renderer).wont_be_same_as before_reset
      end
    end
  end
end
