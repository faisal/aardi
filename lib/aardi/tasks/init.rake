# frozen_string_literal: true

INIT_FILES_DIR = File.expand_path("../init_files", __dir__)

desc("Scaffold a new aardi site")
task :init do
  Dir.glob("#{INIT_FILES_DIR}/**/*", File::FNM_DOTMATCH).each do |src|
    next if File.directory?(src)

    dest = File.basename(src)

    unless File.exist?(dest)
      FileUtils.cp(src, dest)
      puts "Created #{dest}"
      next
    end

    loop do
      print "#{dest} already exists. Overwrite? [y]es / [n]o: "
      answer = $stdin.gets&.strip&.downcase
      case answer
      when "y"
        FileUtils.cp(src, dest)
        puts "Overwrote #{dest}"
        break
      when "n"
        puts "Skipped #{dest}"
        break
      end
    end
  end

  FileUtils.mkdir_p("posts")

  puts "Site scaffolding installed."
  puts "Edit config.yml and .template.html, then run `rake` to build."
end
