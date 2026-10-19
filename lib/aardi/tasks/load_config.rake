# frozen_string_literal: true

task :load_config do
  Aardi::Config.load './config.yml'
end
