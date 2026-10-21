# frozen_string_literal: true

require 'spec_helper'

class TestRenderable
  include Aardi::Renderable

  attr_accessor :target_path

  def content = "# Heading\n\nBody.\n"

  def title = 'Test Renderable'
end

class RenderableSpec < Minitest::Spec
  describe Aardi::Renderable do
    before do
      setup_config
      @tmpdir = Dir.mktmpdir
      make_renderer(
        html_files: Set.new,
        content_hashes: Aardi::ContentHashes.new(File.join(@tmpdir, 'hashes.txt'))
      )
    end

    after do
      FileUtils.rm_rf(@tmpdir)
    end

    describe '#metadata' do
      it 'returns a Metadata instance' do
        _(TestRenderable.new.metadata).must_be_kind_of Aardi::Metadata
      end

      it 'memoizes the same Metadata instance' do
        renderable = TestRenderable.new

        _(renderable.metadata).must_be_same_as renderable.metadata
      end
    end

    describe '#mtime' do
      it 'returns nil when default #children is empty' do
        _(TestRenderable.new.mtime).must_be_nil
      end
    end

    describe '#render' do
      it 'writes the target file via the default #write_target' do
        renderable = TestRenderable.new
        renderable.target_path = File.join(@tmpdir, 'test.html')

        capture_io { renderable.render }

        _(File.exist?(renderable.target_path)).must_equal true
      end

      it 'rendered output includes the content body' do
        renderable = TestRenderable.new
        renderable.target_path = File.join(@tmpdir, 'test.html')

        capture_io { renderable.render }

        _(File.read(renderable.target_path)).must_include 'Heading'
      end

      it 'returns a hash mapping the target path to its output checksum' do
        renderable = TestRenderable.new
        renderable.target_path = File.join(@tmpdir, 'test.html')
        result = nil
        capture_io { result = renderable.render }

        _(result).must_be_kind_of Hash
        _(result.keys).must_include renderable.target_path
      end
    end

    describe 'classes that include Renderable directly' do
      [Aardi::AbstractFeed, Aardi::Archive, Aardi::Blog, Aardi::Day, Aardi::Home,
       Aardi::Month, Aardi::Post, Aardi::Site, Aardi::Tags, Aardi::Year].each do |klass|
        it "#{klass} includes Renderable" do
          _(klass.include?(Aardi::Renderable)).must_equal true
        end

        it "#{klass} has Object as its superclass" do
          _(klass.superclass).must_equal Object
        end
      end
    end

    describe 'classes that get Renderable from a superclass' do
      [Aardi::ATOMFeed, Aardi::JSONFeed, Aardi::TagBlog].each do |klass|
        it "#{klass} includes Renderable" do
          _(klass.include?(Aardi::Renderable)).must_equal true
        end
      end
    end

    describe 'Post' do
      it 'puts AbstractPageSupport before Renderable in its ancestors' do
        ancestors = Aardi::Post.ancestors

        _(ancestors.index(Aardi::AbstractPageSupport)).must_be :<, ancestors.index(Aardi::Renderable)
      end
    end
  end
end
