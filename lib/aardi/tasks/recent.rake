# frozen_string_literal: true

desc('View recent posts')
task recent: [:load_config] do
  Aardi::Site.new.blog.report_recent
end
