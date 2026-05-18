# frozen_string_literal: true

require 'spec_helper'

class TestAbstractBlog < Aardi::AbstractBlog
  # :reek:Attribute
  attr_accessor :target_path

  def content = "# Heading\n\nBody.\n"

  def title = 'Test Blog'
end

class AbstractBlogSpec < Minitest::Spec
  describe Aardi::AbstractBlog do
    before do
      setup_config
      setup_ledger
      @tmpdir = Dir.mktmpdir
      Aardi.ledger[:html_files] = Set.new
      Aardi.ledger[:content_hashes] = Aardi::ContentHashes.new(File.join(@tmpdir, 'hashes.txt'))
    end

    after do
      FileUtils.rm_rf(@tmpdir)
    end

    describe '#metadata' do
      it 'returns a Metadata instance' do
        _(TestAbstractBlog.new.metadata).must_be_kind_of Aardi::Metadata
      end

      it 'memoizes the same Metadata instance' do
        blog = TestAbstractBlog.new

        _(blog.metadata).must_be_same_as blog.metadata
      end
    end

    describe '#mtime' do
      it 'returns nil when default #children is empty' do
        _(TestAbstractBlog.new.mtime).must_be_nil
      end
    end

    describe '#render' do
      it 'writes the target file via the default #write_target' do
        blog = TestAbstractBlog.new
        blog.target_path = File.join(@tmpdir, 'test.html')

        capture_io { blog.render }

        _(File.exist?(blog.target_path)).must_equal true
      end

      it 'rendered output includes the content body' do
        blog = TestAbstractBlog.new
        blog.target_path = File.join(@tmpdir, 'test.html')

        capture_io { blog.render }

        _(File.read(blog.target_path)).must_include 'Heading'
      end

      it 'returns a hash mapping the target path to its output checksum' do
        blog = TestAbstractBlog.new
        blog.target_path = File.join(@tmpdir, 'test.html')
        result = nil
        capture_io { result = blog.render }

        _(result).must_be_kind_of Hash
        _(result.keys).must_include blog.target_path
      end
    end
  end
end
