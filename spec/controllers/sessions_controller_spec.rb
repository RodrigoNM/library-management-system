require 'rails_helper'

shared_examples 'log in successfully' do
  it 'returns a success response' do
    post user_session_path, params: { user: { email: user.email, password: user.password } }

    parsed_response = JSON.parse(response.body)
    expect(response).to have_http_status(:success)
    expect(parsed_response['message']).to eq 'Logged in successfully.'
    expect(parsed_response['token']).not_to be_nil
  end
end


shared_examples 'log out successfully' do
  it 'returns a success response' do
    post user_session_path, params: { user: { email: user.email, password: user.password } }
    token = JSON.parse(response.body)['token']
    delete destroy_user_session_path, headers: { 'Authorization' => "Bearer #{token}" }

    parsed_response = JSON.parse(response.body)
    expect(response).to have_http_status(:success)
    expect(parsed_response['message']).to eq 'Logged out successfully.'
  end
end

RSpec.describe 'Sessions', type: :request do
  describe 'POST /login' do
    context 'for librarian' do
      let!(:user) { create(:librarian) }

      it_behaves_like 'log in successfully'
    end

    context 'for member' do
      let!(:user) { create(:member) }

      it_behaves_like 'log in successfully'
    end

    it 'returns unauthorized for invalid credentials' do
      post user_session_path, params: { user: { email: 'invalid@example.com', password: 'wrongpassword' } }

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'DELETE /logout' do
    context 'for librarian' do
      let!(:user) { create(:librarian) }
      it_behaves_like 'log out successfully'
    end

    context 'for member' do
      let!(:user) { create(:member) }
      it_behaves_like 'log out successfully'
    end

    it 'returns unauthorized if no valid token provided' do
      delete destroy_user_session_path

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
