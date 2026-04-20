# frozen_string_literal: true

require 'webrick'

module Aardi
  class PathServlet < WEBrick::HTTPServlet::AbstractServlet
    def service(req, res)
      # use index if folder
      path = "./#{req.path}".sub(%r{/$}, '/index.html')

      file = path if File.exist?(path)
      file ||= "#{path}.html" if File.exist?("#{path}.html")
      raise(WEBrick::HTTPStatus::NotFound, "#{path} not found.") unless file

      res.body = File.read(file)
    end
  end
end
