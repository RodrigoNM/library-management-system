class Api::V1::BorrowingsController < ApplicationController
  include AuthenticateUser

  before_action :set_book, only: %i[create return_book]
  before_action :set_borrowing, only: %i[return_book]
  before_action :authorize_librarian!, only: [ :return_book ]

  def create
    if @book.available?
    @borrowing = current_user.borrowings.new(book: @book, borrowed_at: Time.current)
      if @borrowing.save
        render json: @borrowing, status: :created
      else
        render json: @borrowing.errors, status: :unprocessable_entity
      end
    else
      render json: { error: "Book is not available for borrowing" }, status: :unprocessable_entity
    end
  end


  def return_book
    if @borrowing.update(returned_at: Time.current)
      render json: @borrowing, status: :ok
    else
      render json: @borrowing.errors, status: :unprocessable_entity
    end
  end

  private

  def set_book
    @book = Book.find(params[:book_id])
  end

  def set_borrowing
    @borrowing = Borrowing.find(params[:id])
  end

  def authorize_librarian!
    unless current_user.librarian?
      render json: { error: "Only librarians can mark a book as returned" }, status: :unauthorized
    end
  end
end
