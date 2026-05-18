# frozen_string_literal: true

require 'spec_helper'

class AardiSpec < Minitest::Spec
  describe Aardi do
    describe '.reset!' do
      it 'clears config so the next access re-runs the writer/lazy-default' do
        before_reset = Aardi.config
        before_reset.load File.join(SpecHelpers::SAMPLES_DIR, 'minimal_config.yml')
        Aardi.reset!

        Aardi.config.load File.join(SpecHelpers::SAMPLES_DIR, 'minimal_config.yml')

        _(Aardi.config).wont_be_same_as before_reset
      end
    end
  end
end
