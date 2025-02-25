# frozen_string_literal: true

FactoryBot.define do
  factory :customer do
    name { Faker::Name.name }
    address { Faker::Address.full_address }
    orders_count { 1 }
    email { Faker::Internet.email }
  end
end
