# frozen_string_literal: true

require 'simplecov'
SimpleCov.start

require 'minitest/autorun'
require 'minitest/spec'
require 'minitest/reporters'
require 'tempfile'
require 'tmpdir'
require 'time'
require 'aardi'

require_relative 'support/spec_helpers'
require_relative 'support/stub_post'

Minitest::Spec.class_eval do
  include SpecHelpers

  before { Aardi.reset! }
end

Minitest::Reporters.use! Minitest::Reporters::DefaultReporter.new(color: true)
