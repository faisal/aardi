# frozen_string_literal: true

require 'spec_helper'

class FolderSpec < Minitest::Spec
  describe Aardi::Folder do
    before do
      setup_config
      setup_ledger
    end

    describe '.new' do
      it 'accepts a path argument' do
        folder = Aardi::Folder.new('.')

        _(folder).must_be_kind_of Aardi::Folder
      end
    end
  end
end
