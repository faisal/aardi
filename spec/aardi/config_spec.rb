# frozen_string_literal: true

require 'spec_helper'

class ConfigSpec < Minitest::Spec
  describe Aardi::Config do
    def with_config_file(data)
      Tempfile.create(['config', '.yml']) do |file|
        file.write(data.to_yaml)
        file.flush
        yield file.path
      end
    end

    describe '.new' do
      it 'reads config from path' do
        with_config_file('site_url' => 'http://example.com') do |path|
          config = Aardi::Config.new(path)

          _(config[:site_url]).must_equal 'http://example.com'
        end
      end

      it 'transforms top-level string keys to symbols' do
        with_config_file('site_url' => 'http://example.com', 'site_title' => 'T') do |path|
          config = Aardi::Config.new(path)

          _(config[:site_url]).must_equal 'http://example.com'
        end
      end

      it 'transforms markup_options keys to symbols' do
        with_config_file('markup_options' => { 'fenced_code_blocks' => true }) do |path|
          config = Aardi::Config.new(path)

          _(config[:markup_options][:fenced_code_blocks]).must_equal true
        end
      end

      it 'returns nil for missing keys' do
        with_config_file({}) do |path|
          config = Aardi::Config.new(path)

          _(config[:nonexistent]).must_be_nil
        end
      end

      it 'freezes data so a second prepare fails' do
        with_config_file('site_url' => 'http://example.com') do |path|
          config = Aardi::Config.new(path)

          _(proc { config.prepare({ 'x' => 'y' }.to_yaml) }).must_raise
        end
      end
    end
  end
end
