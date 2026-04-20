# frozen_string_literal: true

INIT_FILES_DIR = File.expand_path('../init_files', __dir__)

unless defined?(InitTask)
  module InitTask
    def self.install_file(src)
      dest = File.basename(src)

      if !File.exist?(dest) || prompt_overwrite?(dest)
        FileUtils.cp(src, dest)
        puts "Wrote #{dest}"
      else
        puts "Skipped #{dest}"
      end
    end

    def self.prompt_overwrite?(filename)
      loop do
        print "#{filename} already exists. Overwrite? [y]es / [n]o: "
        case $stdin.gets&.strip&.downcase
        when 'y' then return true
        when 'n' then return false
        end
      end
    end
  end
end

desc('Scaffold a new Aardi site')
task :init do
  Dir.glob("#{INIT_FILES_DIR}/**/*", File::FNM_DOTMATCH).each do |src|
    next if File.directory?(src)

    InitTask.install_file(src)
  end

  puts 'Site scaffolding installed.'
end
