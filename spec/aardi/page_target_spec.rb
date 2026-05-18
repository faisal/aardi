# frozen_string_literal: true

require 'spec_helper'

class PageTargetSpec < Minitest::Spec
  describe Aardi::PageTarget do
    before do
      setup_config
      setup_ledger
      @tmpdir = Dir.mktmpdir
      Aardi.ledger[:content_hashes] = Aardi::ContentHashes.new(File.join(@tmpdir, 'hashes.txt'))
      Aardi.ledger[:html_files] = Set.new
    end

    after do
      FileUtils.rm_rf(@tmpdir)
    end

    def target_path(name = 'page.html')
      File.join(@tmpdir, name)
    end

    it 'does not delete the path from html_files' do
      path = target_path
      src = Aardi::PageContent.new("# Title\n", 'Title')
      Aardi.ledger[:html_files].add(path)
      Aardi.ledger[:content_hashes][path] = src.output_hash
      capture_io { Aardi::PageTarget.new(src, path).write }

      _(Aardi.ledger[:html_files]).must_include path
    end

    it 'returns {path => output_hash}' do
      path = target_path
      src = Aardi::PageContent.new("# Title\n", 'Title')
      result = nil
      capture_io { result = Aardi::PageTarget.new(src, path).write }

      _(result).must_equal({ path => src.output_hash })
    end

    it 'uses html_files to determine if the file exists (not the filesystem)' do
      path = target_path
      Aardi.ledger[:html_files].add(path)
      src = Aardi::PageContent.new("# Title\n", 'Title')
      Aardi.ledger[:content_hashes][path] = src.output_hash
      out, = capture_io { Aardi::PageTarget.new(src, path).write }

      _(out).must_be_empty
      _(File.exist?(path)).must_equal false
    end

    it 'writes when path is not in html_files' do
      path = target_path
      src = Aardi::PageContent.new("# Title\n", 'Title')
      capture_io { Aardi::PageTarget.new(src, path).write }

      _(File.exist?(path)).must_equal true
    end
  end
end
