# frozen_string_literal: true

require 'spec_helper'

class ConfigSpec < Minitest::Spec
  describe Aardi::Config do
    before do
      Aardi::Config.reset
    end

    describe '.load' do
      it 'reads config from file' do
        Tempfile.create(['config', '.yml']) do |file|
          file.write({ 'site_url' => 'http://example.com' }.to_yaml)
          file.flush

          Aardi::Config.load(file.path)
        end

        _(Aardi::Config[:site_url]).must_equal 'http://example.com'
      end

      it 'transforms top-level string keys to symbols' do
        config_yaml = { 'site_url' => 'http://example.com', 'site_title' => 'T' }.to_yaml
        Aardi::Config.prepare config_yaml

        _(Aardi::Config[:site_url]).must_equal 'http://example.com'
      end

      it 'transforms markup_options keys to symbols' do
        config_yaml = { 'markup_options' => { 'fenced_code_blocks' => true } }.to_yaml
        Aardi::Config.prepare config_yaml

        _(Aardi::Config[:markup_options][:fenced_code_blocks]).must_equal true
      end

      it 'rejects a second load' do
        config_yaml = { 'site_url' => 'http://example.com' }.to_yaml
        Aardi::Config.prepare config_yaml

        _(proc { Aardi::Config.prepare config_yaml }).must_raise
      end

      it 'raises for missing keys' do
        config_yaml = {}.to_yaml
        Aardi::Config.prepare config_yaml

        _(proc { Aardi::Config[:nonexistent] }).must_raise
      end
    end
  end
end
