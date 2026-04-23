# frozen_string_literal: true

desc('View recent posts')
task :recent do
  config = Aardi::Config.new('./config.yml')
  Aardi::Site.new(config:).blog.report_recent
end
