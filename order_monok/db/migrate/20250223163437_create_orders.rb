# frozen_string_literal: true

# Migration for creating the orders table with necessary fields and indexes.
class CreateOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :orders do |t|
      t.integer :customer_id, null: false
      t.string :product_name, null: false
      t.integer :quantity, null: false, default: 1
      t.decimal :price, null: false, precision: 10, scale: 2
      t.string :status, null: false, default: "pending"

      t.timestamps
    end

    add_index :orders, :customer_id
    add_index :orders, :status
  end
end
