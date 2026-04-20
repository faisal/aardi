# frozen_string_literal: true

require_relative 'lib/aardi/version'

Gem::Specification.new do |s|
  s.name = 'aardi'
  s.version = Aardi::VERSION
  s.summary = 'A static site generator.'
  s.authors = ['Faisal N Jawdat']
  s.email = 'aardi@faisal.com'
  s.license = 'MIT'
  s.required_ruby_version = '>= 3.3'

  s.metadata['homepage_uri'] = 'https://github.com/faisal/aardi'
  s.metadata['source_code_uri'] = s.homepage
  s.metadata['bug_tracker_uri'] = "#{s.homepage}/issues"
  s.metadata['changelog_uri'] = "#{s.homepage}/blob/main/CHANGELOG.md"
  s.metadata['documentation_uri'] = "#{s.homepage}/blob/main/README.md"
  s.metadata['rubygems_mfa_required'] = 'true'

  s.files = Dir['lib/**/*']

  s.add_dependency 'git'
  s.add_dependency 'nokogiri'
  s.add_dependency 'rake'
  s.add_dependency 'redcarpet'
  s.add_dependency 'webrick'
end
