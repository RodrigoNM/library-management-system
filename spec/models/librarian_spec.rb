require 'rails_helper'

RSpec.describe Librarian do
  describe 'callbacks' do
    context 'when creating a new Librarian' do
      it 'sets role to librarian' do
        librarian = build(:librarian)
        expect(librarian.librarian?).to be true
      end
    end
  end
end
