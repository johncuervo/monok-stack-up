module Messaging
  class Publisher
    class PublishError < StandardError; end

    # Publishes a message to a specified exchange with the provided payload and routing key
    def self.publish(payload, routing_key:, exchange_name: nil)
      new.publish(payload, routing_key: routing_key)
    end

    def publish(payload, routing_key:)
      # Establishes a new channel and default exchange for publishing messages
      channel = connection.create_channel
      exchange = channel.default_exchange

      exchange.publish(
        payload.to_json,
        routing_key: routing_key,
        persistent: true,
        content_type: "application/json"
      )
    ensure
      channel.close if channel.open?
    end

    private

    # Creates and starts a connection to RabbitMQ using Bunny
    def connection
      @connection ||= Bunny.new(connection_params).tap(&:start)
    end

    def connection_params
      {
        host: ENV.fetch("RABBIT_HOST", "localhost"),
        port: ENV.fetch("RABBIT_PORT", 5672),
        vhost: ENV.fetch("RABBIT_VHOST", "/"),
        username: ENV.fetch("RABBIT_USERNAME", "guest"),
        password: ENV.fetch("RABBIT_PASSWORD", "guest")
      }
    end
  end
end
