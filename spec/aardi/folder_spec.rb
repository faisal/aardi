# frozen_string_literal: true

require 'spec_helper'

class FolderSpec < Minitest::Spec
  describe Aardi::Folder do
    before do
      @config = setup_config
      @ledger = setup_ledger(config: @config)
    end

    describe '.new' do
      it 'accepts config and ledger keyword arguments' do
        folder = Aardi::Folder.new('.', config: @config, ledger: @ledger)

        _(folder).must_be_kind_of Aardi::Folder
      end
    end
  end
end
