# frozen_string_literal: true

# Migration to create the customers table with required fields and a unique index on email.
class CreateCustomers < ActiveRecord::Migration[8.0]
  def change
    create_table :customers do |t|
      t.string :name, null: false
      t.string :address, null: false
      t.integer :orders_count, null: false, default: 0
      t.string :email, null: false

      t.timestamps
    end

    add_index :customers, :email, unique: true
  end
end
