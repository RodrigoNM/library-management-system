require 'faker'

FactoryBot.define do
  factory :book do
    title { Faker::Book.title }
    author { Faker::Book.author }
    genre { Faker::Book.genre }
    isbn { Faker::Number.unique.number(digits: 13).to_s }
    total_copies { Faker::Number.between(from: 1, to: 100) }
  end
end
