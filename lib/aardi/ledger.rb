# frozen_string_literal: true

module Aardi
  class Ledger
    def initialize
      @data = {}
    end

    def [](key) = @data[key]

    def []=(key, value)
      @data[key] = value
    end
  end
end
