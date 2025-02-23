class Order < ApplicationRecord
  enum :status, {
    pending: "pending",
    processing: "processing",
    completed: "completed",
    cancelled: "cancelled"
  }

  validates :customer_id, :product_name, :quantity, :price, :status, presence: true
  validates :customer_id, :quantity, numericality: { only_integer: true, greater_than: 0 }
  validates :price, numericality: { greater_than: 0 }

  after_commit :publish_created_event, on: :create

  scope :by_customer, ->(customer_id) { where(customer_id: customer_id) }

  private

  def publish_created_event
    OrderPublisher.order_created(self)
  end
end
