FactoryBot.define do
  factory :member do
    email { 'member@example.com' }
    password { 'password' }
    role { :member }
  end
end
