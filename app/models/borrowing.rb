class Borrowing < ApplicationRecord
  belongs_to :user
  belongs_to :book

  validates :user_id, uniqueness: { scope: :book_id, message: "has already borrowed this book" }
  validates :due_date, presence: true
  # validate :book_must_be_available

  scope :borrowed_books_count, -> { where(returned_at: nil).count }
  scope :due_today, -> { where(due_date: Date.today).count }

  def overdue?
    return false if returned_at.present?

    Time.current > due_date
  end

  def book_must_be_available
    errors.add(:book, "is not available") unless book.available?
  end
end
