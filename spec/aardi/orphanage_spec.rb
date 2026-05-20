# frozen_string_literal: true

require 'spec_helper'

class OrphanageSpec < Minitest::Spec
  describe Aardi::Orphanage do
    before do
      setup_config
    end

    describe '#report' do
      it 'prints paths in html_files that were not generated' do
        setup_config ignore_orphans: []
        _, err = capture_io { Aardi::Orphanage.new.report(Set.new(['./orphan.html']), []) }

        _(err).must_include 'Orphan: ./orphan.html'
      end

      it 'does not report paths that appear in generated_paths' do
        html_files = Set.new(['./orphan.html', './generated.html'])
        _, err = capture_io { Aardi::Orphanage.new.report(html_files, ['./generated.html']) }

        _(err).must_include 'Orphan: ./orphan.html'
        _(err).wont_include 'generated.html'
      end

      it 'does not print paths matching an ignore_orphans prefix' do
        setup_config ignore_orphans: ['./ignored/']
        _, err = capture_io { Aardi::Orphanage.new.report(Set.new(['./ignored/page.html']), []) }

        _(err).must_be_empty
      end

      it 'prints non-ignored paths while silencing ignored ones' do
        setup_config ignore_orphans: ['./ignored/']
        _, err = capture_io { Aardi::Orphanage.new.report(Set.new(['./ignored/page.html', './visible.html']), []) }

        _(err).must_include 'visible.html'
        _(err).wont_include 'ignored/page.html'
      end

      it 'does nothing when html_files is empty' do
        _, err = capture_io { Aardi::Orphanage.new.report(Set.new, []) }

        _(err).must_be_empty
      end

      it 'does not crash when :ignore_orphans is present with a nil value' do
        setup_config ignore_orphans: nil
        _, err = capture_io { Aardi::Orphanage.new.report(Set.new(['./orphan.html']), []) }

        _(err).must_include 'Orphan: ./orphan.html'
      end

      it 'does not crash when :ignore_orphans is absent from config' do
        setup_config ignore_orphans: SpecHelpers::OMIT
        _, err = capture_io { Aardi::Orphanage.new.report(Set.new(['./orphan.html']), []) }

        _(err).must_include 'Orphan: ./orphan.html'
      end
    end
  end
end
