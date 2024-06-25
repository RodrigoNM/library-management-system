require 'rails_helper'

RSpec.describe "Books", type: :request do
  let(:librarian) { create(:librarian) }
  let(:member) { create(:member) }
  let(:book) { create(:book) }

  describe "POST /books" do
    context "when user is a librarian" do
      it "creates a new book" do
        post user_session_path, params: { user: { email: librarian.email, password: librarian.password } }
        token = JSON.parse(response.body)['token']

        expect {
          post api_v1_books_path, params: { book: attributes_for(:book) }, headers: {
            'Authorization' => "Bearer #{token}"
          }
        }.to change(Book, :count).by(1)
      end
    end

    context "when user is a member" do
      it "denies book creation" do
        post user_session_path, params: { user: { email: member.email, password: member.password } }
        token = JSON.parse(response.body)['token']

        expect do
          post api_v1_books_path, params: { book: attributes_for(:book) }, headers: { 'Authorization' => "Bearer #{token}" }
        end.to raise_error Pundit::NotAuthorizedError
      end
    end
  end

  describe "PATCH /books/:id" do
    context "when user is a librarian" do
      it "allows book update" do
        post user_session_path, params: { user: { email: librarian.email, password: librarian.password } }
        token = JSON.parse(response.body)['token']
        put "/api/v1/books/#{book.id}", params: { book: attributes_for(:book) }, headers: { 'Authorization' => "Bearer #{token}" }

        expect(response).to have_http_status(:ok)
      end
    end

    context "when user is a member" do
      it "denies book update" do
        post user_session_path, params: { user: { email: member.email, password: member.password } }
        token = JSON.parse(response.body)['token']

        expect do
          put "/api/v1/books/#{book.id}", params: { book: attributes_for(:book) }, headers: { 'Authorization' => "Bearer #{token}" }
        end.to raise_error Pundit::NotAuthorizedError
      end
    end
  end

  describe "DELETE /books/:id" do
    context "when user is a librarian" do
      it "allows book deletion" do
        post user_session_path, params: { user: { email: librarian.email, password: librarian.password } }
        token = JSON.parse(response.body)['token']
        delete "/api/v1/books/#{book.id}", headers: { 'Authorization' => "Bearer #{token}" }

        expect(response).to have_http_status(:no_content)
      end
    end

    context "when user is a member" do
      it "denies book deletion" do
        post user_session_path, params: { user: { email: member.email, password: member.password } }
        token = JSON.parse(response.body)['token']

        expect do
          delete "/api/v1/books/#{book.id}", headers: { 'Authorization' => "Bearer #{token}" }
        end.to raise_error Pundit::NotAuthorizedError
      end
    end
  end

  describe 'POST #borrow' do
    context 'when member is authenticated' do
      context 'when book can be borrowed' do
        it 'creates a new borrowing' do
          post user_session_path, params: { user: { email: member.email, password: member.password } }
          token = JSON.parse(response.body)['token']

          expect {
            post borrow_api_v1_book_path(book), headers: { 'Authorization' => "Bearer #{token}" }
          }.to change(Borrowing, :count).by(1)
          expect(response).to have_http_status(:ok)
          expect(JSON.parse(response.body)['message']).to eq('Book was successfully borrowed.')
        end
      end

      context 'when member tries to borrow the same book again' do
        before do
          member.borrowings.create(book: book, due_date: 2.weeks.from_now)
        end

        it 'does not create a new borrowing' do
          post user_session_path, params: { user: { email: member.email, password: member.password } }
          token = JSON.parse(response.body)['token']
          expect do
            post borrow_api_v1_book_path(book), headers: { 'Authorization' => "Bearer #{token}" }
          end.to raise_error Pundit::NotAuthorizedError
        end
      end
    end
  end

  describe 'POST #return' do
    let!(:borrowing) { Borrowing.create(user: librarian, book: book, due_date: 2.weeks.from_now) }

    context 'when librarian is authenticated' do
      context 'when book can be returned' do
        it 'marks the book as returned' do
          post user_session_path, params: { user: { email: librarian.email, password: librarian.password } }
          token = JSON.parse(response.body)['token']

          expect {
            post return_api_v1_book_path(book), headers: { 'Authorization' => "Bearer #{token}" }
          }.to change { borrowing.reload.returned_at }.from(nil)
          expect(response).to have_http_status(:ok)
          expect(JSON.parse(response.body)['message']).to eq('Book was successfully returned.')
        end
      end

      context 'when book has already been returned' do
        before do
          borrowing.update(returned_at: Time.current)
        end

        it 'does not update the return status' do
          post user_session_path, params: { user: { email: librarian.email, password: librarian.password } }
          token = JSON.parse(response.body)['token']
          expect do
            post return_api_v1_book_path(book), headers: { 'Authorization' => "Bearer #{token}" }
          end.to raise_error Pundit::NotAuthorizedError
        end
      end
    end

    context 'when a member tries to return a book' do
      it 'returns unauthorized status' do
        post user_session_path, params: { user: { email: member.email, password: member.password } }
        token = JSON.parse(response.body)['token']
        expect do
          post return_api_v1_book_path(book), headers: { 'Authorization' => "Bearer #{token}" }
        end.to raise_error Pundit::NotAuthorizedError
      end
    end
  end
end
