# frozen_string_literal: true

require 'spec_helper'

class AardiSpec < Minitest::Spec
  describe Aardi do
    describe '.ledger' do
      it 'returns a Ledger instance' do
        _(Aardi.ledger).must_be_kind_of Aardi::Ledger
      end

      it 'memoizes the same instance across calls' do
        _(Aardi.ledger).must_be_same_as Aardi.ledger
      end
    end

    describe '.reset!' do
      it 'clears ledger so the next access returns a fresh instance' do
        before_reset = Aardi.ledger
        Aardi.reset!

        _(Aardi.ledger).wont_be_same_as before_reset
      end

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
