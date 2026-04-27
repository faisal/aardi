# frozen_string_literal: true

require 'spec_helper'

class MonthSpec < Minitest::Spec
  describe Aardi::Month do
    before do
      @config = setup_config
      @ledger = Aardi::Ledger.new
    end

    def make_month(month_int = 1)
      year = Aardi::Year.new(2024, 'blog', config: @config, ledger: @ledger)
      Aardi::Month.new(year, month_int, 'blog', config: @config, ledger: @ledger)
    end

    describe '#<<' do
      it 'routes a post to the correct day' do
        month = make_month
        post = StubPost.new(Time.now)
        month << post

        _(month.count).must_equal 1
      end
    end

    describe '#count' do
      it 'sums post counts across all days' do
        month = make_month
        month << StubPost.new(Time.now)
        month << StubPost.new(Time.now)
        month << StubPost.new(Time.now)

        _(month.count).must_equal 3
      end

      it 'returns zero when no posts' do
        _(make_month.count).must_equal 0
      end
    end

    describe '#title' do
      it 'formats as month name and year' do
        _(make_month(3).title).must_equal 'March 2024'
      end

      describe 'with tag' do
        def make_month_with_tag
          year = Aardi::Year.new(2024, 'blog', config: @config, ledger: @ledger)
          Aardi::Month.new(year, 3, 'blog', config: @config, ledger: @ledger, tag: 'ruby')
        end

        it 'includes tag in title' do
          _(make_month_with_tag.title).must_equal 'March 2024 - ruby'
        end
      end
    end

    describe '#target_path' do
      it 'includes archive_path, year, month, and index.html' do
        month = make_month(4)

        _(month.target_path).must_equal './blog/2024/04/index.html'
      end
    end

    describe '#archive_cell' do
      before do
        setup_config
      end

      it "returns ' |' for a month with no posts" do
        month = make_month
        fmt = '[%<count>s](http://example.com/blog/%<year>s/%<month>s/)'

        _(month.archive_cell(fmt)).must_equal ' |'
      end

      it 'returns a formatted link for a month with posts' do
        month = make_month(2)
        month << StubPost.new(Time.now)
        fmt = '[%<count>s](/blog/%<year>s/%<month>s/)'
        cell = month.archive_cell(fmt)

        _(cell).must_include '1'
        _(cell).must_include '/blog/2024/02/'
      end
    end

    describe '#content' do
      it 'includes the month title heading' do
        month = make_month(5)
        month << StubPost.new(Time.now)

        _(month.content).must_include '# May 2024'
      end
    end
  end
end
