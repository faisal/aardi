# frozen_string_literal: true

require_relative "lib/aardi/version"

Gem::Specification.new do |s|
  s.name = "aardi"
  s.version = Aardi::VERSION
  s.summary = "A static site generator."
  s.authors = ["Faisal N Jawdat"]
  s.license = "MIT"
  s.files = Dir["lib/**/*"]
  s.required_ruby_version = ">= 4.0"

  s.add_dependency "git"
  s.add_dependency "nokogiri"
  s.add_dependency "rake"
  s.add_dependency "redcarpet"
  s.add_dependency "webrick"

  s.add_development_dependency "reek"
  s.add_development_dependency "rubocop-ordered_methods"
  s.add_development_dependency "rubocop-performance"
  s.add_development_dependency "rubocop-rake"
  s.add_development_dependency "rubocop-rubyfmt"
  s.add_development_dependency "rubocop"
  s.add_development_dependency "standard", ">= 1.35.1"
  s.metadata["rubygems_mfa_required"] = "true"
end
