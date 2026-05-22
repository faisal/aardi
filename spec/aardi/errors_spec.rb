# frozen_string_literal: true

require 'spec_helper'

class ErrorsSpec < Minitest::Spec
  describe Aardi::MissingPathError do
    it 'is a StandardError' do
      _(Aardi::MissingPathError.ancestors).must_include StandardError
    end
  end
end
