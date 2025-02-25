# frozen_string_literal: true

require 'faker'

# Clear the database before seeding
Customer.destroy_all

# Create 10 random customers
10.times do
  Customer.create!(
    name: Faker::Name.name,
    email: Faker::Internet.email,
    address: Faker::Address.full_address,
    orders_count: rand(0..10)
  )
end

puts "✅ 10 customers have been created."
