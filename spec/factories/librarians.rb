FactoryBot.define do
  factory :librarian do
    email { 'librarian@example.com' }
    password { 'password' }
    role { :librarian }
  end
end
