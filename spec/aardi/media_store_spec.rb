# frozen_string_literal: true

require 'spec_helper'
require 'aardi/media_store'

class MediaStoreSpec < Minitest::Spec
  describe Aardi::MediaStore do
    before do
      @tmpdir = Dir.mktmpdir
      @original_dir = Dir.pwd
      Dir.chdir(@tmpdir)
      setup_config(template_path: File.join(SpecHelpers::SAMPLES_DIR, 'minimal_template.html'))
    end

    after do
      Dir.chdir(@original_dir)
      FileUtils.rm_rf(@tmpdir)
    end

    subject { Aardi::MediaStore.new }

    it 'writes the bytes under the media directory and returns the site url' do
      result = subject.save(name: 'photo.png', bytes: 'BINARYDATA')

      _(File.binread(File.join('media', 'photo.png'))).must_equal 'BINARYDATA'
      _(result['url']).must_equal 'http://example.com/media/photo.png'
    end

    it 'sanitizes a name containing directory components to its basename' do
      result = subject.save(name: '../../etc/evil.png', bytes: 'X')

      _(File.exist?(File.join('media', 'evil.png'))).must_equal true
      _(result['url']).must_equal 'http://example.com/media/evil.png'
    end
  end
end
