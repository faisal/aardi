# frozen_string_literal: true

desc('Visit home page')
task :homepage do
  config = Aardi::Config.new('./config.yml')
  system("open #{config[:site_url]}")
end
