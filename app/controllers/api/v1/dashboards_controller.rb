class Api::V1::DashboardsController < ApplicationController
  include AuthenticateUser

  def index
    if current_user.librarian?
      render json: librarian_dashboard_data, status: :ok
    else
      render json: member_dashboard_data, status: :ok
    end
  end

  private

  def librarian_dashboard_data
    {
      total_books: Book.count(:id),
      total_borrowed_books: Borrowing.count(:id),
      books_due_today: Borrowing.due_today
    }
  end

  def member_dashboard_data
    {
      borrowed_books: current_user.borrowed_books.map(&:due_date)
    }
  end
end
