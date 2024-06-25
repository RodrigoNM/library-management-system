require 'rails_helper'

RSpec.describe Member do
  describe 'callbacks' do
    context 'when creating a new Member' do
      it 'sets default role to member on creation' do
        member = build(:member)
        expect(member.member?).to be true
      end
    end
  end
end
