# frozen_string_literal: true

require 'spec_helper'

class AbstractBlogSpec < Minitest::Spec
  describe Aardi::AbstractBlog do
    let(:expected_warning) { deprecation_message('Aardi::AbstractBlog', 'Aardi::Renderable') }

    it 'includes Renderable' do
      _(Aardi::AbstractBlog.include?(Aardi::Renderable)).must_equal true
    end

    describe 'deprecation warning' do
      it 'names the caller location when a subclass is instantiated' do
        klass = Class.new(Aardi::AbstractBlog)

        _ { klass.new }.must_output '', deprecation_warning_at(__FILE__, __LINE__, expected_warning)
      end

      it 'is issued when a subclass #initialize does not call super' do
        klass = Class.new(Aardi::AbstractBlog) { define_method(:initialize) { |posts| @posts = posts } }

        _(deprecation_count(expected_warning) { klass.new([]) }).must_equal 1
      end
    end
  end
end
