# frozen_string_literal: true

# rubocop:disable Rake/Desc
task :load_config do
  Aardi.config.load "./config.yml"
end
# rubocop:enable Rake/Desc
