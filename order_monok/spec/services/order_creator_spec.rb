# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OrderCreator do
  let(:service_url) { ENV.fetch("CUSTOMER_SERVICE_URL", "http://customer-service.test") }

  describe '.create' do
    let(:order_params) do
      {
        customer_id: customer_id,
        product_name: 'Test Product',
        quantity: 1,
        price: 100,
        status: 'pending'
      }
    end

    let(:customer_id) { 1 }

    context 'when customer exists' do
      before do
        stub_request(:get, "#{service_url}/api/v1/customers/#{customer_id}")
          .to_return(
            status: 200,
            body: { id: customer_id }.to_json,
            headers: { 'Content-Type': 'application/json' }
          )
      end

      it 'creates a new order' do
        expect {
          described_class.create(order_params)
        }.to change(Order, :count).by(1)
      end

      it 'sets correct attributes' do
        order = described_class.create(order_params)

        expect(order).to have_attributes(
                           customer_id: customer_id,
                           product_name: 'Test Product',
                           quantity: 1,
                           price: 100,
                           status: 'pending'
                         )
      end
    end

    context 'when customer does not exist' do
      before do
        stub_request(:get, "#{service_url}/api/v1/customers/#{customer_id}")
          .to_return(status: 404)
      end

      it 'raises CustomerNotFoundError' do
        expect {
          described_class.create(order_params)
        }.to raise_error(CustomerService::CustomerNotFoundError)
      end
    end

    context 'when order params are invalid' do
      let(:invalid_params) do
        {
          customer_id: customer_id,
          price: -100
        }
      end

      before do
        stub_request(:get, "#{service_url}/api/v1/customers/#{customer_id}")
          .to_return(
            status: 200,
            body: { id: customer_id }.to_json,
            headers: { 'Content-Type': 'application/json' }
          )
      end

      it 'raises RecordInvalid' do
        expect {
          described_class.create(invalid_params)
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end
