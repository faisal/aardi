# frozen_string_literal: true

require 'spec_helper'
require 'rake'

class RenderRakeSpec < Minitest::Spec
  describe 'rake render' do
    before do
      setup_config
      Rake.application = Rake::Application.new
      Rake::Task.define_task(:load_config)
      load File.expand_path('../../lib/aardi/tasks/render.rake', __dir__)
    end

    it 'aborts with the error message when MissingPathError is raised' do
      mock_site = Object.new
      mock_site.define_singleton_method(:render) { raise Aardi::MissingPathError, '/missing/ is missing' }
      Aardi::Site.define_singleton_method(:new) { mock_site }

      begin
        _, err = capture_io do
          assert_raises(SystemExit) { Rake.application[:render].invoke }
        end
        _(err).must_include '/missing/'
      ensure
        Aardi::Site.singleton_class.remove_method(:new)
      end
    end
  end
end
