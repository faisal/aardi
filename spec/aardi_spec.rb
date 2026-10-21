# frozen_string_literal: true

require 'spec_helper'
require 'open3'
require 'rbconfig'

class AardiSpec < Minitest::Spec
  describe Aardi do
    describe '.renderer' do
      it 'returns an Aardi::Renderer instance' do
        setup_config
        make_renderer

        _(Aardi.renderer).must_be_instance_of Aardi::Renderer
      end

      it 'returns the same instance on repeated calls' do
        setup_config
        make_renderer

        _(Aardi.renderer).must_be_same_as Aardi.renderer
      end

      it 'can be replaced by injecting a new renderer' do
        setup_config
        first = make_renderer
        second = make_renderer

        _(Aardi.renderer).must_be_same_as second
        _(Aardi.renderer).wont_be_same_as first
      end
    end

    describe '.reset!' do
      it 'clears config so it can be reloaded' do
        Aardi::Config.load File.join(SpecHelpers::SAMPLES_DIR, 'minimal_config.yml')
        Aardi.reset!

        _(proc { Aardi::Config.load File.join(SpecHelpers::SAMPLES_DIR, 'minimal_config.yml') }).must_be_silent
      end

      it 'clears renderer so the next access creates a fresh instance' do
        setup_config
        before_reset = make_renderer
        setup_config
        make_renderer

        _(Aardi.renderer).wont_be_same_as before_reset
      end
    end

    describe "require 'aardi'" do
      def run_script(script)
        lib_dir = File.expand_path('../lib', __dir__)
        Open3.capture3(RbConfig.ruby, '-I', lib_dir, '-e', script)
      end

      %w[AbstractBlog AbstractPageSupport].each do |shim|
        it "loads #{shim}" do
          output, _err, status = run_script("require 'aardi'; print defined?(Aardi::#{shim}).inspect")

          _(status.success?).must_equal true
          _(output).must_equal '"constant"'
        end
      end

      it 'prints no warnings on load' do
        _output, err, status = run_script("require 'aardi'")

        _(status.success?).must_equal true
        _(err).must_be_empty
      end
    end
  end
end
