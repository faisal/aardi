# frozen_string_literal: true

require 'spec_helper'

class YearSpec < Minitest::Spec
  describe Aardi::Year do
    before do
      setup_config
    end

    def make_year(year_int = 2024)
      Aardi::Year.new(year_int, 'blog')
    end

    describe '#<<' do
      it 'routes a post to the correct month' do
        year = make_year
        year << StubPost.new(Time.utc(2024, 6, 1))
        year << StubPost.new(Time.utc(2024, 6, 15))
        row = year.archive_row('%<year>s %<months>s', '%<month>s(%<count>s)')
        _(row).must_include '06(2)'
      end
    end

    describe '#title' do
      it 'returns the year as a string' do
        _(make_year(2023).title).must_equal '2023'
      end

      it 'includes tag in title' do
        _(Aardi::Year.new(2023, 'blog', tag: 'ruby').title).must_equal '2023 - ruby'
      end
    end

    describe '#target_path' do
      it 'includes archive_path, year, and index.html' do
        _(make_year(2022).target_path).must_equal './blog/2022/index.html'
      end
    end

    describe '#archive_row' do
      it 'includes the year and 12 month cells' do
        year = make_year
        row = year.archive_row("| %<year>s | %<months>s\n", '[%<count>s](http://example.com/blog/%<year>s/%<month>s/)')
        _(row).must_include '| 2024 |'
      end
    end

    describe '#content' do
      it 'includes a heading and links to each month with posts' do
        year = make_year(2024)
        year << StubPost.new(Time.utc(2024, 6, 1))
        _(year.content).must_include '# 2024'
        _(year.content).must_include 'June'
      end
    end
  end
end
