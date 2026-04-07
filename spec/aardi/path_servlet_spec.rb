# frozen_string_literal: true

require "spec_helper"
require "webrick"
require "aardi/path_servlet"
require_relative "../support/fake_request"
require_relative "../support/fake_response"

class PathServletSpec < Minitest::Spec
  describe Aardi::PathServlet do
    before do
      @tmpdir = Dir.mktmpdir
      @original_dir = Dir.pwd
      Dir.chdir(@tmpdir)
    end

    after do
      Dir.chdir(@original_dir)
      FileUtils.rm_rf(@tmpdir)
    end

    # :reek:TooManyStatements
    def fake_server
      server = Object.new
      logger = WEBrick::Log.new(File::NULL)
      server.define_singleton_method(:logger) { logger }
      server.define_singleton_method(:[]) { |_key| nil }
      server
    end

    subject do
      Aardi::PathServlet.new(fake_server, {})
    end

    it "serves index.html when the request path ends with '/'" do
      File.write("./index.html", "<html>home</html>")
      res = FakeResponse.new
      subject.service(FakeRequest.new("/"), res)
      _(res.body).must_include "home"
    end

    it "serves an existing file directly" do
      File.write("./about.html", "<html>about</html>")
      res = FakeResponse.new
      subject.service(FakeRequest.new("/about.html"), res)
      _(res.body).must_include "about"
    end

    it "appends .html and serves when path.html exists" do
      File.write("./contact.html", "<html>contact</html>")
      res = FakeResponse.new
      subject.service(FakeRequest.new("/contact"), res)
      _(res.body).must_include "contact"
    end

    it "raises NotFound when neither the path nor path.html exists" do
      _(proc { subject.service(FakeRequest.new("/missing"), FakeResponse.new) })
        .must_raise WEBrick::HTTPStatus::NotFound
    end
  end
end
