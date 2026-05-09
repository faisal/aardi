# frozen_string_literal: true

require 'spec_helper'

class SiteSpec < Minitest::Spec
  describe Aardi::Site do
    before do
      setup_config(template_path: File.join(SpecHelpers::SAMPLES_DIR, 'minimal_template.html'),
                   blog_posts_path: File.join(SpecHelpers::SAMPLES_DIR, 'nonexistent_posts'),
                   content_hashes_path: '/nonexistent_test_hashes')
    end

    describe '#initialize' do
      it 'constructs without arguments' do
        _(Aardi::Site.new).must_be_kind_of Aardi::Site
      end
    end

    describe '#blog' do
      it 'returns a Blog instance' do
        _(Aardi::Site.new.blog).must_be_kind_of Aardi::Blog
      end

      it 'memoizes the same Blog instance' do
        site = Aardi::Site.new

        _(site.blog).must_be_same_as site.blog
      end
    end
  end
end
