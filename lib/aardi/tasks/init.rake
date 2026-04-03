# frozen_string_literal: true

desc("Scaffold a new aardi site")
task :init do
  if File.exist?("config.yml")
    puts "config.yml already exists, skipping"
  else
    File.write("config.yml", <<~YAML)
      site_title: My Site
      site_url: http://localhost:8000
      site_author: Author Name
      files_to_exclude:
        - ./a
        - ./posts
      ignore_orphans: []
      template_path: .template.html
      blog_archive_path: a
      blog_posts_path: posts
      blog_feed_posts: 10
      blog_recent_posts: 10
      blog_archive_title: Blog Archive
      blog_home_title: My Site
      blog_home_posts: 10
      sitemap_entries:
        /: daily
      markup_options:
        autolink: false
        fenced_code_blocks: true
        footnotes: true
        no_intra_emphasis: true
        strikethrough: true
        superscript: true
        tables: true
      content_hashes_path: .content_hashes.txt
    YAML
    puts "Created config.yml"
  end

  if File.exist?(".template.html")
    puts ".template.html already exists, skipping"
  else
    File.write(".template.html", <<~HTML)
      <!DOCTYPE html>
      <html lang="en">
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <meta name="description" content="">
        <title></title>
      </head>
      <body>
        <main>
        </main>
      </body>
      </html>
    HTML
    puts "Created .template.html"
  end

  FileUtils.mkdir_p("posts")
  puts "Created posts/ directory" unless Dir.empty?("posts")

  puts "Site scaffolded. Edit config.yml, then run `rake` to build."
end
