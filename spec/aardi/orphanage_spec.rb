# frozen_string_literal: true

require 'spec_helper'

class OrphanageSpec < Minitest::Spec
  describe Aardi::Orphanage do
    before do
      @config = setup_config
      @ledger = Aardi::Ledger.new
    end

    describe '#report' do
      it 'prints paths that are in html_files but not ignored' do
        @config = setup_config ignore_orphans: []
        @ledger[:html_files] = Set.new(['./orphan.html'])
        _, err = capture_io { Aardi::Orphanage.new(config: @config, ledger: @ledger).report }

        _(err).must_include 'Orphan: ./orphan.html'
      end

      it 'does not print paths matching an ignore_orphans prefix' do
        @config = setup_config ignore_orphans: ['./ignored/']
        @ledger[:html_files] = Set.new(['./ignored/page.html'])
        _, err = capture_io { Aardi::Orphanage.new(config: @config, ledger: @ledger).report }

        _(err).must_be_empty
      end

      it 'prints non-ignored paths while silencing ignored ones' do
        @config = setup_config ignore_orphans: ['./ignored/']
        @ledger[:html_files] = Set.new(['./ignored/page.html', './visible.html'])
        _, err = capture_io { Aardi::Orphanage.new(config: @config, ledger: @ledger).report }

        _(err).must_include 'visible.html'
        _(err).wont_include 'ignored/page.html'
      end

      it 'does nothing when html_files is empty' do
        @ledger[:html_files] = Set.new
        _, err = capture_io { Aardi::Orphanage.new(config: @config, ledger: @ledger).report }

        _(err).must_be_empty
      end

      it 'does not crash when ignore_orphans is absent from config' do
        @config = setup_config ignore_orphans: nil
        @ledger[:html_files] = Set.new(['./orphan.html'])
        _, err = capture_io { Aardi::Orphanage.new(config: @config, ledger: @ledger).report }

        _(err).must_include 'Orphan: ./orphan.html'
      end
    end
  end
end
