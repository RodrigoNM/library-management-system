class Book < ApplicationRecord
  has_many :borrowings
  has_many :borrowers, through: :borrowings, source: :user

  def available?
    borrowings.where(returned_at: nil).empty?
  end
end
