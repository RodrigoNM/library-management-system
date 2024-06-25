class User < ApplicationRecord
  has_many :borrowings
  has_many :borrowed_books, through: :borrowings, source: :book

  enum role: { member: 0, librarian: 1 }

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: Devise::JWT::RevocationStrategies::Null

  def overdue_borrowings
    borrowings.where("due_date < ? AND returned_at IS NULL", Date.today)
  end
end
