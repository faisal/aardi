# frozen_string_literal: true

require 'spec_helper'

class HomeFooterLinksSpec < Minitest::Spec
  describe Aardi::HomeFooterLinks do
    before { setup_config }

    describe 'without blog_path' do
      subject { Aardi::HomeFooterLinks.new(nil) }

      it 'includes Archive, RSS, and JSON labels' do
        _(subject.to_s).must_include 'Archive'
        _(subject.to_s).must_include 'RSS'
        _(subject.to_s).must_include 'JSON'
      end

      it 'builds archive URL from site_url and blog_archive_path' do
        _(subject.to_s).must_include 'http://example.com/blog/'
      end

      it 'builds feed URLs from site_url' do
        _(subject.to_s).must_include 'http://example.com/index.xml'
        _(subject.to_s).must_include 'http://example.com/index.json'
      end
    end

    describe 'with blog_path' do
      subject { Aardi::HomeFooterLinks.new('tags/foo') }

      it 'includes blog_path in feed URLs' do
        _(subject.to_s).must_include 'http://example.com/tags/foo/index.xml'
        _(subject.to_s).must_include 'http://example.com/tags/foo/index.json'
      end
    end
  end
end
