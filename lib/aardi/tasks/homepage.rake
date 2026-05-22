# frozen_string_literal: true

desc('Visit home page')
task homepage: [:load_config] do
  system('open', Aardi::Config[:site_url])
end
