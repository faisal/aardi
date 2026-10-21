# frozen_string_literal: true

require 'spec_helper'

class DeprecationSpec < Minitest::Spec
  describe Aardi::Deprecation do
    let(:expected_warning) { deprecation_message('OldThing', 'NewThing') }

    it 'names the caller location and the replacement' do
      user = Class.new

      _ { Aardi::Deprecation.warn_once('OldThing', user, 'NewThing') }
        .must_output '', deprecation_warning_at(__FILE__, __LINE__ - 1, expected_warning)
    end

    it 'is issued only once for one shim and one class' do
      user = Class.new

      count = deprecation_count(expected_warning) do
        2.times { Aardi::Deprecation.warn_once('OldThing', user, 'NewThing') }
      end

      _(count).must_equal 1
    end

    it 'is issued again for a different class' do
      count = deprecation_count(expected_warning) do
        2.times { Aardi::Deprecation.warn_once('OldThing', Class.new, 'NewThing') }
      end

      _(count).must_equal 2
    end

    it 'is issued again for a different shim' do
      user = Class.new
      other_message = deprecation_message('OtherThing', 'NewThing')

      _, err = capture_io do
        Aardi::Deprecation.warn_once('OldThing', user, 'NewThing')
        Aardi::Deprecation.warn_once('OtherThing', user, 'NewThing')
      end

      _(err.scan(expected_warning).size).must_equal 1
      _(err.scan(other_message).size).must_equal 1
    end
  end
end
