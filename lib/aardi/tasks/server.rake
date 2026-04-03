# frozen_string_literal: true

desc("Run a server")
task :server do
  require "aardi/path_servlet"

  port = 8000
  url = "http://localhost:#{port}/"
  root = "."
  puts(url)

  server = WEBrick::HTTPServer.new(Port: port, DocumentRoot: root)
  server.mount("/", Aardi::PathServlet)

  trap("INT") { server.shutdown }
  system("(open '#{url}')&")
  server.start
end
