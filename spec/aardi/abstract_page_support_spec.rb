# frozen_string_literal: true

require 'spec_helper'

class AbstractPageSupportSpec < Minitest::Spec
  describe Aardi::AbstractPageSupport do
    let(:expected_warning) { deprecation_message('Aardi::AbstractPageSupport', 'Aardi::PageSupport') }

    it 'includes PageSupport' do
      _(Aardi::AbstractPageSupport.include?(Aardi::PageSupport)).must_equal true
    end

    describe 'deprecation warning' do
      it 'names the caller location when included in a class' do
        klass = Class.new

        _ { klass.include(Aardi::AbstractPageSupport) }
          .must_output '', deprecation_warning_at(__FILE__, __LINE__ - 1, expected_warning)
      end

      it 'is issued when an object is extended' do
        klass = Class.new

        _(deprecation_count(expected_warning) { klass.new.extend(Aardi::AbstractPageSupport) }).must_equal 1
      end

      it 'is issued only once for each class of extended objects' do
        klass = Class.new

        _(deprecation_count(expected_warning) { 2.times { klass.new.extend(Aardi::AbstractPageSupport) } }).must_equal 1
      end
    end
  end
end
