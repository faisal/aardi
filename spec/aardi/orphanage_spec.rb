# frozen_string_literal: true

require "spec_helper"

class OprhanageSpec < Minitest::Spec
  describe Aardi::Orphanage do
    before do
      Aardi.reset!
    end

    describe "#report" do
      it "prints paths that are in html_files but not ignored" do
        setup_config("ignore_orphans" => [])
        Aardi.ledger[:html_files] = Set.new(["./orphan.html"])
        _, err = capture_io { Aardi::Orphanage.new.report }

        _(err).must_include "Orphan: ./orphan.html"
      end

      it "does not print paths matching an ignore_orphans prefix" do
        setup_config("ignore_orphans" => ["./ignored/"])
        Aardi.ledger[:html_files] = Set.new(["./ignored/page.html"])
        _, err = capture_io { Aardi::Orphanage.new.report }

        _(err).must_be_empty
      end

      it "prints non-ignored paths while silencing ignored ones" do
        setup_config("ignore_orphans" => ["./ignored/"])
        Aardi.ledger[:html_files] = Set.new(["./ignored/page.html", "./visible.html"])
        _, err = capture_io { Aardi::Orphanage.new.report }

        _(err).must_include "visible.html"
        _(err).wont_include "ignored/page.html"
      end

      it "does nothing when html_files is empty" do
        setup_config
        Aardi.ledger[:html_files] = Set.new
        _, err = capture_io { Aardi::Orphanage.new.report }

        _(err).must_be_empty
      end
    end
  end
end
