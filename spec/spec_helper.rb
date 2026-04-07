# frozen_string_literal: true

require "minitest/autorun"
require "minitest/spec"
require "minitest/reporters"
require "tempfile"
require "tmpdir"
require "time"
require "aardi"

require_relative "support/spec_helpers"
require_relative "support/stub_post"

Minitest::Spec.class_eval { include SpecHelpers }

Minitest::Reporters.use! Minitest::Reporters::DefaultReporter.new(color: true)
