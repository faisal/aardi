# frozen_string_literal: true

require 'spec_helper'

class AbstractFeedSpec < Minitest::Spec
  describe Aardi::AbstractFeed do
    let(:expected_warning) { deprecation_message('Aardi::AbstractFeed', 'Aardi::Feed') }

    it 'is a subclass of Feed' do
      _(Aardi::AbstractFeed.superclass).must_equal Aardi::Feed
    end

    describe 'deprecation warning' do
      it 'names the caller location when a subclass is instantiated' do
        klass = Class.new(Aardi::AbstractFeed)

        _ { klass.new([]) }.must_output '', deprecation_warning_at(__FILE__, __LINE__, expected_warning)
      end
    end
  end
end
