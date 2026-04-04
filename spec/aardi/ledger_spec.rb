# frozen_string_literal: true

require "spec_helper"

class LedgerSpec < Minitest::Spec
  describe Aardi::Ledger do
    before { Aardi.reset! }

    it "stores and retrieves values by key" do
      Aardi.ledger[:foo] = "bar"
      expect(Aardi.ledger[:foo]).must_equal "bar"
    end

    it "returns nil for unset keys" do
      expect(Aardi.ledger[:missing]).must_be_nil
    end

    it "stores multiple independent keys" do
      Aardi.ledger[:a] = 1
      Aardi.ledger[:b] = 2
      expect(Aardi.ledger[:a]).must_equal 1
      expect(Aardi.ledger[:b]).must_equal 2
    end
  end
end
