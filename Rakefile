# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rake/testtask'
require 'rubocop/rake_task'
require 'reek/rake/task'

RuboCop::RakeTask.new(:rubocop)

Rake::TestTask.new(:spec) do |task|
  task.pattern = 'spec/**/*_spec.rb'
  task.libs << 'spec'
  task.libs << 'lib'
end

Reek::Rake::Task.new(:reek)

desc('Alias for spec')
task test: :spec

task all: %i[spec rubocop reek]

task default: :all
