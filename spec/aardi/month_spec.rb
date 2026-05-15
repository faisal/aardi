# frozen_string_literal: true

require 'spec_helper'

class MonthSpec < Minitest::Spec
  describe Aardi::Month do
    before do
      setup_config
    end

    def make_month(month_int = 1)
      year = Aardi::Year.new(2024, 'blog')
      Aardi::Month.new(year, month_int, 'blog')
    end

    describe '#<<' do
      it 'routes a post to the correct day' do
        month = make_month
        month << StubPost.new(Time.now)
        _(month.count).must_equal 1
      end
    end

    describe '#count' do
      it 'sums post counts across all days' do
        month = make_month
        3.times { month << StubPost.new(Time.now) }
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

      it 'includes tag in title' do
        year = Aardi::Year.new(2024, 'blog')
        _(Aardi::Month.new(year, 3, 'blog', 'foo').title).must_equal 'March 2024 - foo'
      end
    end

    describe '#target_path' do
      it 'includes archive_path, year, month, and index.html' do
        _(make_month(4).target_path).must_equal './blog/2024/04/index.html'
      end
    end

    describe '#archive_cell' do
      it "returns ' |' for a month with no posts" do
        _(make_month.archive_cell('[%<count>s](http://example.com/blog/%<year>s/%<month>s/)')).must_equal ' |'
      end

      it 'returns a formatted link for a month with posts' do
        month = make_month(2)
        month << StubPost.new(Time.now)
        cell = month.archive_cell('[%<count>s](/blog/%<year>s/%<month>s/)')
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

    describe '#children (private)' do
      it 'returns the days sorted by descending key' do
        month = make_month(6)
        month << StubPost.new(Time.utc(2024, 6, 5))
        month << StubPost.new(Time.utc(2024, 6, 20))

        _(month.send(:children).map(&:key)).must_equal [20, 5]
      end
    end
  end
end
