# frozen_string_literal: true

require "spec_helper"

class ConfigSpec < Minitest::Spec
  describe Aardi::Config do
    before { Aardi.reset! }

    describe "#load" do
      it "transforms top-level string keys to symbols" do
        Tempfile.create(["cfg", ".yml"]) do |file|
          file.write({"site_url" => "http://test.com", "site_title" => "T"}.to_yaml)
          file.flush

          Aardi.config.load(file.path)
        end

        expect(Aardi.config[:site_url]).must_equal "http://test.com"
      end

      it "transforms markup_options keys to symbols" do
        Tempfile.create(["cfg", ".yml"]) do |file|
          file.write({"markup_options" => {"fenced_code_blocks" => true}}.to_yaml)
          file.flush

          Aardi.config.load(file.path)
        end

        expect(Aardi.config[:markup_options][:fenced_code_blocks]).must_equal true
      end

      it "freezes data after loading" do
        Tempfile.create(["cfg", ".yml"]) do |file|
          file.write({"site_url" => "http://test.com"}.to_yaml)
          file.flush

          Aardi.config.load(file.path)
        end

        Tempfile.create(["cfg2", ".yml"]) do |file|
          file.write({"site_url" => "http://other.com"}.to_yaml)
          file.flush

          expect(proc { Aardi.config.load(file.path) }).must_raise FrozenError
        end
      end

      it "returns nil for missing keys" do
        Tempfile.create(["cfg", ".yml"]) do |file|
          file.write({}.to_yaml)
          file.flush

          Aardi.config.load(file.path)
        end

        expect(Aardi.config[:nonexistent]).must_be_nil
      end
    end
  end
end
