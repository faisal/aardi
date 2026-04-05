# frozen_string_literal: true

require "spec_helper"
require "rake"

class NowRakeSpec < Minitest::Spec
  describe "rake now" do
    before do
      Rake.application = Rake::Application.new
      load File.expand_path("../../lib/aardi/tasks/now.rake", __dir__)
    end

    it "outputs a line beginning with 'Updated: '" do
      out, = capture_io { Rake.application[:now].invoke }
      _(out).must_match(/^Updated: /)
    end

    it "includes a UTC ISO8601 timestamp" do
      out, = capture_io { Rake.application[:now].invoke }
      # ISO8601 format: YYYY-MM-DDTHH:MM:SSZ
      _(out.chomp).must_match(/^Updated: \d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$/)
    end
  end
end
