# frozen_string_literal: true

desc('Render new or updated files [DEFAULT]')
task :render do
  config = Aardi::Config.new.load('./config.yml')
  Aardi::Site.new(config:).render
end
