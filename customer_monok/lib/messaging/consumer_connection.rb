module Messaging
  class ConsumerConnection
    class ConsumptionError < StandardError; end

    # Starts a new instance of ConsumerConnection and initiates the connection
    # to the specified RabbitMQ queue.
    def self.start(queue_name)
      new.start(queue_name)
    end

    # Initializes the connection to RabbitMQ and creates a channel.
    def initialize
      @connection = Bunny.new(connection_params).tap(&:start)
      @channel = @connection.create_channel
    end

    # Starts the consumer by subscribing to the provided queue name.
    # If there's an error, a ConsumptionError is raised.
    def start(queue_name)
      queue = channel.queue(queue_name)
      queue
    rescue StandardError => e
      raise ConsumptionError, "Failed to consume message: #{e.message}"
    end

    private

    attr_reader :connection, :channel

    def connection_params
      {
        host: ENV.fetch("RABBIT_HOST", "localhost"),
        port: ENV.fetch("RABBIT_PORT", 5672),
        vhost: ENV.fetch("RABBIT_VHOST", "/"),
        username: ENV.fetch("RABBIT_USER", "guest"),
        password: ENV.fetch("RABBIT_PASSWORD", "guest")
      }
    end
  end
end
