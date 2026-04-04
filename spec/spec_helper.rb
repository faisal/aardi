# frozen_string_literal: true

require "minitest/autorun"
require "minitest/spec"
require "tempfile"
require "tmpdir"
require "time"
require "aardi"

require_relative "support/spec_helpers"
require_relative "support/stub_post"

Minitest::Spec.class_eval { include SpecHelpers }
