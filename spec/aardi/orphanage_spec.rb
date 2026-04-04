# frozen_string_literal: true

require "spec_helper"

class OprhanageSpec < Minitest::Spec
  describe Aardi::Orphanage do
    before { Aardi.reset! }

    describe "#warn" do
      it "prints paths that are in html_files but not ignored" do
        setup_config("ignore_orphans" => [])
        Aardi.ledger[:html_files] = Set.new(["./orphan.html"])
        out, = capture_io { Aardi::Orphanage.new.warn }
        expect(out).must_include "Orphan: ./orphan.html"
      end

      it "does not print paths matching an ignore_orphans prefix" do
        setup_config("ignore_orphans" => ["./ignored/"])
        Aardi.ledger[:html_files] = Set.new(["./ignored/page.html"])
        out, = capture_io { Aardi::Orphanage.new.warn }
        expect(out).must_be_empty
      end

      it "prints non-ignored paths while silencing ignored ones" do
        setup_config("ignore_orphans" => ["./ignored/"])
        Aardi.ledger[:html_files] = Set.new(["./ignored/page.html", "./visible.html"])
        out, = capture_io { Aardi::Orphanage.new.warn }
        expect(out).must_include "visible.html"
        expect(out).wont_include "ignored/page.html"
      end

      it "does nothing when html_files is empty" do
        setup_config
        Aardi.ledger[:html_files] = Set.new
        out, = capture_io { Aardi::Orphanage.new.warn }
        expect(out).must_be_empty
      end
    end
  end
end
