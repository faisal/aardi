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

    describe '.fetch' do
      it 'returns the value when the key is present' do
        Aardi::Config.prepare({ 'site_url' => 'http://example.com' }.to_yaml)

        _(Aardi::Config.fetch(:site_url)).must_equal 'http://example.com'
      end

      it 'returns nil when the key is missing and no default is given' do
        Aardi::Config.prepare({}.to_yaml)

        _(Aardi::Config.fetch(:nonexistent)).must_be_nil
      end

      it 'returns the default when the key is missing' do
        Aardi::Config.prepare({}.to_yaml)

        _(Aardi::Config.fetch(:nonexistent, 'fallback')).must_equal 'fallback'
      end

      it 'returns the value (not the default) when the key is present' do
        Aardi::Config.prepare({ 'site_url' => 'http://example.com' }.to_yaml)

        _(Aardi::Config.fetch(:site_url, 'fallback')).must_equal 'http://example.com'
      end

      it 'returns nil (not the default) when the key is present with a nil value' do
        Aardi::Config.prepare({ 'site_url' => nil }.to_yaml)

        _(Aardi::Config.fetch(:site_url, 'fallback')).must_be_nil
      end
    end

    describe '.reset' do
      it 'restores raise-on-miss for queries after reset (before re-load)' do
        Aardi::Config.prepare({ 'site_url' => 'http://example.com' }.to_yaml)
        Aardi::Config.reset

        _(proc { Aardi::Config[:nonexistent] }).must_raise KeyError
      end

      it 'still raises for missing keys after reset and a fresh load' do
        Aardi::Config.prepare({ 'site_url' => 'http://example.com' }.to_yaml)
        Aardi::Config.reset
        Aardi::Config.prepare({ 'site_url' => 'http://example.com' }.to_yaml)

        _(proc { Aardi::Config[:nonexistent] }).must_raise KeyError
      end
    end
  end
end
