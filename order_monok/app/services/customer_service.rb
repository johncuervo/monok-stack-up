# frozen_string_literal: true

require "faraday"
require "json"

# Handles communication with the Customer Service API.
# Fetches customer details and manages errors related to API requests.
class CustomerService
  class CustomerNotFoundError < StandardError; end
  class ServiceError < StandardError; end

  class << self
    # Retrieves a customer by their ID, handling potential errors during the request
    def get_customer(id)
      response = connection.get("api/v1/customers/#{id}")
      handle_response(response)
    rescue Faraday::Error => e
      handle_connection_error(e)
    end

    private

    # Establishes a connection to the customer service API using Faraday
    # The connection is memoized to avoid creating multiple instances.
    def connection
      @connection ||= Faraday.new(url: service_url) do |f|
        f.request :json
        f.response :json
        f.response :logger, Rails.logger, bodies: true
        f.adapter Faraday.default_adapter
        f.options.timeout = 5
      end
    end

    def service_url
      ENV.fetch("CUSTOMER_SERVICE_URL", nil)
    end

    # Handles the response from the customer service API based on the status code
    def handle_response(response)
      case response.status
      when 200
        response.body
      when 404
        raise CustomerNotFoundError, "Customer not found"
      else
        handle_error_response(response)
      end
    end

    def handle_error_response(response)
      error_message = "Customer service error: #{response.status}"
      error_message += " - #{response.body['error']}" if response.body&.key?("error")

      Rails.logger.error(error_message)

      raise ServiceError, error_message
    end

    def handle_connection_error(error)
      Rails.logger.error("Connection error: #{error.message}")
      raise ServiceError, "Service is unavailable"
    end
  end
end
