class Librarian < User
  after_initialize :set_role, if: :new_record?

  def set_role
    self.role = :librarian
  end
end
