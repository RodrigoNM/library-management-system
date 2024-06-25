class Api::V1::BooksController < ApplicationController
  include AuthenticateUser
  include Pundit

  before_action :set_book, only: %i[update destroy borrow return]
  after_action :verify_authorized, only: %i[create update destroy]

    def create
      @book = Book.new(book_params)
      if @book.save
        render json: @book, status: :created
      else
        render json: @book.errors, status: :unprocessable_entity
      end
    end

    def update
      if @book.update(book_params)
        render json: @book
      else
        render json: @book.errors, status: :unprocessable_entity
      end
    end

    def destroy
      @book.destroy
      head :no_content
    end

    def search
      @books = Book.where("title LIKE ? OR author LIKE ? OR genre LIKE ?", "%#{params[:query]}%", "%#{params[:query]}%", "%#{params[:query]}%")
      render json: @books
    end

    def borrow
      authorize @book

      borrowing = current_user.borrowings.new(book: @book, due_date: 2.weeks.from_now)
      if borrowing.save
        render json: { message: "Book was successfully borrowed." }, status: :ok
      else
        render json: { error: "Could not borrow the book." }, status: :unprocessable_entity
      end
    end

    def return
      authorize @book

      borrowing = Borrowing.find_by(book: @book, returned_at: nil)
      if borrowing&.update(returned_at: Time.current)
        render json: { message: "Book was successfully returned." }, status: :ok
      else
        render json: { error: "Could not return the book." }, status: :unprocessable_entity
      end
    end

    private

    def verify_authorized
      authorize Book
    end

    def set_book
      @book = Book.find(params[:id])
    end

    def book_params
      params.require(:book).permit(:title, :author, :genre, :isbn, :total_copies)
    end
end
