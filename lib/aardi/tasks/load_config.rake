# frozen_string_literal: true

# rubocop:disable-next Rake/Desc
task :load_config do
  Aardi::Config.load './config.yml'
end
