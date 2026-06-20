# frozen_string_literal: true

desc('View draft posts')
task drafts: [:load_config] do
  Aardi::Site.new.blog.report_drafts
end
