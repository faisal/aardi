# frozen_string_literal: true

desc("Render new or updated files [DEFAULT]")
task render: [:load_config] do
  Aardi::Site.new.render
end
