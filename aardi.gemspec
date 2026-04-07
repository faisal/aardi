# frozen_string_literal: true

require_relative "lib/aardi/version"

Gem::Specification.new do |s|
  s.name = "aardi"
  s.version = Aardi::VERSION
  s.summary = "A static site generator."
  s.authors = ["Faisal N Jawdat"]
  s.email = "aardi@faisal.com"
  s.license = "MIT"
  s.files = Dir["lib/**/*"]
  s.required_ruby_version = ">= 3.3"
  s.metadata = {
    "homepage_uri" => "https://github.com/faisal/aardi",
    "source_code_uri" => "https://github.com/faisal/aardi",
    "bug_tracker_uri" => "https://github.com/faisal/aardi/issues",
    "changelog_uri" => "https://github.com/faisal/aardi/blob/main/CHANGELOG.md",
    "documentation_uri" => "https://github.com/faisal/aardi/blob/main/README.md"
  }

  s.add_dependency "git"
  s.add_dependency "nokogiri"
  s.add_dependency "rake"
  s.add_dependency "redcarpet"
  s.add_dependency "webrick"

  s.add_development_dependency "flog"
  s.add_development_dependency "reek"
  s.add_development_dependency "rubocop-minitest"
  s.add_development_dependency "rubocop-ordered_methods"
  s.add_development_dependency "rubocop-performance"
  s.add_development_dependency "rubocop-rake"
  s.add_development_dependency "rubocop"
  s.add_development_dependency "minitest"
  s.add_development_dependency "minitest-reporters"
  s.add_development_dependency "standard", ">= 1.35.1"
  s.metadata["rubygems_mfa_required"] = "true"
end
