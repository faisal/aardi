# frozen_string_literal: true

require 'spec_helper'

class DaySpec < Minitest::Spec
  describe Aardi::Day do
    before do
      setup_config
    end

    def make_day(day_int = 15)
      year = Aardi::Year.new(2024, 'blog')
      month = Aardi::Month.new(year, 1, 'blog')
      Aardi::Day.new(year, month, day_int, 'blog')
    end

    describe '#<<' do
      it 'adds a post' do
        day = make_day
        day << StubPost.new(Time.now)
        _(day.count).must_equal 1
      end
    end

    describe '#count' do
      it 'returns the number of posts' do
        day = make_day
        2.times { day << StubPost.new(Time.now) }
        _(day.count).must_equal 2
      end
    end

    describe '#title' do
      it 'formats the date as a human-readable string' do
        day = make_day(15)

        _(day.title).must_include 'January 2024'
        _(day.title).must_include '15'
      end

      it 'includes tag in title' do
        year = Aardi::Year.new(2024, 'blog')
        month = Aardi::Month.new(year, 1, 'blog')
        day = Aardi::Day.new(year, month, 15, 'blog', tag: 'ruby')
        _(day.title).must_equal 'Monday, 15 January 2024 - ruby'
      end
    end

    describe '#target_path' do
      it 'includes archive_path, year, month, day, and index.html' do
        _(make_day(5).target_path).must_equal './blog/2024/01/05/index.html'
      end
    end

    describe '#content' do
      it 'includes a heading with the day title' do
        day = make_day
        day << StubPost.new(Time.now)

        _(day.content).must_match(/\A# .*January 2024/)
      end

      it 'includes content from all posts' do
        day = make_day
        day << StubPost.new(Time.now, title: 'First')
        day << StubPost.new(Time.now, title: 'Second')

        _(day.content).must_include 'First'
        _(day.content).must_include 'Second'
      end

      it 'orders posts reverse chronologically (newest first)' do
        day = make_day
        base = Time.utc(2024, 1, 15, 12, 0, 0)
        day << StubPost.new(base, title: 'Noon')
        day << StubPost.new(base - 3600, title: 'Morning')
        day << StubPost.new(base - 1800, title: 'Late Morning')
        content = day.content

        _(content.index('Noon')).must_be :<, content.index('Late Morning')
        _(content.index('Late Morning')).must_be :<, content.index('Morning')
      end
    end
  end
end
