# frozen_string_literal: true

require "spec_helper"

class LedgerSpec < Minitest::Spec
  describe Aardi::Ledger do
    before do
      Aardi.reset!
    end

    it "stores and retrieves values by key" do
      Aardi.ledger[:foo] = "bar"
      _(Aardi.ledger[:foo]).must_equal "bar"
    end

    it "returns nil for unset keys" do
      _(Aardi.ledger[:missing]).must_be_nil
    end

    it "stores multiple independent keys" do
      Aardi.ledger[:a] = 1
      Aardi.ledger[:b] = 2
      _(Aardi.ledger[:a]).must_equal 1
      _(Aardi.ledger[:b]).must_equal 2
    end
  end
end
