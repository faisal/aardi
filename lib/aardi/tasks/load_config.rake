# frozen_string_literal: true

# rubocop:disable Rake/Desc
task :load_config do
  Aardi::Config.load './config.yml'
end
# rubocop:enable Rake/Desc
