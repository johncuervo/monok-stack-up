class OrderPublisher
  EXCHANGE_NAME = "orders".freeze

  class << self
    # Publishes an event when an order is created
    def order_created(order)
      publish_event("orders.created", serialize_order(order))
    end

    private

    # Publishes an event to the messaging system with the provided routing key and payload

    def publish_event(routing_key, payload)
      Messaging::Publisher.publish(
        payload,
        routing_key: routing_key,
        exchange_name: EXCHANGE_NAME
      )
    end

    def serialize_order(order)
      {
        id: order.id,
        customer_id: order.customer_id,
        status: order.status,
        updated_at: order.updated_at
      }
    end
  end
end
