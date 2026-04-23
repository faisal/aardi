# frozen_string_literal: true

desc('Visit home page')
task :homepage do
  config = Aardi::Config.new.load('./config.yml')
  system("open #{config[:site_url]}")
end
