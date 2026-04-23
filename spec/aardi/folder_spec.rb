# frozen_string_literal: true

require 'spec_helper'

class FolderSpec < Minitest::Spec
  describe Aardi::Folder do
    before do
      setup_config
      setup_ledger
      @config = Aardi.config
      @ledger = Aardi.ledger
    end

    describe '.new' do
      it 'accepts config and ledger keyword arguments' do
        folder = Aardi::Folder.new('.', config: @config, ledger: @ledger)

        _(folder).must_be_kind_of Aardi::Folder
      end
    end
  end
end
