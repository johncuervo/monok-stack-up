# frozen_string_literal: true

class Customer < ApplicationRecord
  validates :name, :address, presence: true
  validates :orders_count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
end
