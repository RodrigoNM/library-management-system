class BookPolicy < ApplicationPolicy
  # NOTE: Up to Pundit v2.3.1, the inheritance was declared as
  # `Scope < Scope` rather than `Scope < ApplicationPolicy::Scope`.
  # In most cases the behavior will be identical, but if updating existing
  # code, beware of possible changes to the ancestors:
  # https://gist.github.com/Burgestrand/4b4bc22f31c8a95c425fc0e30d7ef1f5
  def create?
    user_is_librarian?
  end

  def update?
    user_is_librarian?
  end

  def destroy?
    user_is_librarian?
  end

  def borrow?
    user_is_a_member? && !user.borrowed_books.include?(record)
  end

  def return?
    user_is_librarian? && Borrowing.exists?(book: record, returned_at: nil)
  end

  private

  def user_is_librarian?
    user.librarian?
  end

  def user_is_a_member?
    user.member?
  end
end
