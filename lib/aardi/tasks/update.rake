# frozen_string_literal: true

desc("Render new or updated files [DEFAULT]")
task update: [:load_config] do
  Aardi::Site.new.render
end
