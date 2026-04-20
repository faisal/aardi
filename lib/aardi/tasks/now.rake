# frozen_string_literal: true

desc('Produce an Updated header with current timestamp')
task :now do
  puts "Updated: #{Time.now.utc.iso8601}"
end
