class Member < User
  after_initialize :set_role, if: :new_record?

  def overdue_books
    borrowings.where("due_date < ? AND returned_at IS NULL", Date.today)
  end

  def set_role
    self.role = :member
  end
end
