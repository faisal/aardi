# frozen_string_literal: true

desc('Fix file timestamps')
task(:fixtimes) do
  require 'aardi/timekeeper'

  Aardi::Timekeeper.new.run
end
