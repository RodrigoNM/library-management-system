require 'rails_helper'

RSpec.describe "Dashboards", type: :request do
  let(:librarian) { create(:librarian) }
  let(:member) { create(:member) }
  let(:books) { create_list(:book, 5) }
  let(:borrowing) { 2.times { Borrowing.create(user: member, book: books.sample, due_date: 2.weeks.from_now) } }

  describe "GET /index" do
    context "when user is a librarian" do
      it "returns librarian dashboard data" do
        post user_session_path, params: { user: { email: librarian.email, password: librarian.password } }
        token = JSON.parse(response.body)['token']
        get api_v1_dashboards_path, headers: { 'Authorization' => "Bearer #{token}" }

        expected_hash = { "total_books"=>0, "total_borrowed_books"=>0, "books_due_today"=>0 }
        parsed_response = JSON.parse(response.body)
        expect(parsed_response).to eq expected_hash
      end
    end

    context "when user is a member" do
      it "returns member dashbaord data" do
        post user_session_path, params: { user: { email: member.email, password: member.password } }
        token = JSON.parse(response.body)['token']
        get api_v1_dashboards_path, headers: { 'Authorization' => "Bearer #{token}" }

        expected_hash = { "borrowed_books"=>[] }
        parsed_response = JSON.parse(response.body)
        expect(parsed_response).to eq expected_hash
      end
    end
  end
end
