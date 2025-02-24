# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CustomerService do
  let(:service_url) { ENV.fetch("CUSTOMER_SERVICE_URL", "http://customer-service.test") }
  let(:customer_id) { 1 }

  describe '.get_customer' do
    context 'when customer exists' do
      before do
        stub_request(:get, "#{service_url}/api/v1/customers/#{customer_id}")
          .to_return(
            status: 200,
            body: { id: customer_id, name: "Test Customer" }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'returns customer data' do
        response = described_class.get_customer(customer_id)
        expect(response).to include('id' => customer_id)
      end
    end

    context 'when customer not found' do
      before do
        stub_request(:get, "#{service_url}/api/v1/customers/#{customer_id}")
          .to_return(status: 404)
      end

      it 'raises CustomerNotFoundError' do
        expect {
          described_class.get_customer(customer_id)
        }.to raise_error(CustomerService::CustomerNotFoundError)
      end
    end

    context 'when service returns error' do
      before do
        stub_request(:get, "#{service_url}/api/v1/customers/#{customer_id}")
          .to_return(
            status: 500,
            body: { error: "Internal Server Error" }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'raises ServiceError' do
        expect {
          described_class.get_customer(customer_id)
        }.to raise_error(CustomerService::ServiceError)
      end
    end

    context 'when connection fails' do
      before do
        stub_request(:get, "#{service_url}/api/v1/customers/#{customer_id}")
          .to_timeout
      end

      it 'raises ServiceError' do
        expect {
          described_class.get_customer(customer_id)
        }.to raise_error(CustomerService::ServiceError)
      end
    end
  end
end
