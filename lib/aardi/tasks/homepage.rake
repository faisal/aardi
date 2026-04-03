# frozen_string_literal: true

desc("Visit home page")
task homepage: [:load_config] do
  system("open #{Aardi.config[:site_url]}")
end
