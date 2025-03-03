# frozen_string_literal: true

# OrderCreatedConsumer listens to the "orders.created" queue and updates the
# customer's order count when a new order is created.
class OrderCreatedConsumer
  class << self
    # Starts the consumer and subscribes to the "orders.created" queue.
    def start
      queue = Messaging::ConsumerConnection.start("orders.created")
      queue.subscribe(block: true) do |_delivery_info, _properties, body|
        event_data = JSON.parse(body)
        handle_message(event_data)
        process_order_event(event_data)
      rescue JSON::ParserError => e
        Rails.logger.info "Failed to parse message: #{e.message}"
      end
    end

    private

    # Processes the order event and updates the customer's order count.
    def process_order_event(event_data)
      customer = find_customer(event_data["customer_id"])
      return unless customer

      update_customer_orders_count(customer)
    end

    def find_customer(customer_id)
      Customer.find_by(id: customer_id)
    end

    def update_customer_orders_count(customer)
      customer.increment!(:orders_count)
      Rails.logger.info("Updated orders_count for customer #{customer.id}")
    end

    def handle_message(event_data)
      Rails.logger.info "New Message Received"
      process_event(event_data)
    end

    def process_event(event_data)
      Rails.logger.info "Processing event: #{event_data}"
    end
  end
end
