# frozen_string_literal: true

def create_new_post(config)
  now = Time.now.utc
  new_post_file = "#{now.to_i}.md"
  new_post_path = "#{config[:blog_posts_path]}/#{new_post_file.hash.modulo(36).to_s(36)}/#{new_post_file}"
  new_post_content = "Creation: #{now.iso8601}\n\n----\n### title\n\n[source](url): \"excerpt\"\n"
  FileUtils.mkdir_p(File.dirname(new_post_path))
  File.write(new_post_path, new_post_content)
  puts(new_post_path)
end

desc('Create a new blog post and reveal it in Finder')
task :new do
  config = Aardi::Config.new.load('./config.yml')
  create_new_post(config)
end
