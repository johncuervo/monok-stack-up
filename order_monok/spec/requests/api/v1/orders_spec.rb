# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Api::V1::Orders", type: :request do
  let(:service_url) { ENV.fetch("CUSTOMER_SERVICE_URL", "http://customer-service.test") }

  describe "GET /api/v1/orders" do
    before do
      create_list(:order, 2, customer_id: customer_id)
      create_list(:order, 2, customer_id: other_customer_id)
    end

    let(:customer_id) { 1 }
    let(:other_customer_id) { 2 }

    it "returns orders for specific customer" do
      get api_v1_orders_path, params: { customer_id: customer_id }

      expect(response).to have_http_status(:ok)
      expect(json_response.size).to eq(2)
      expect(json_response.pluck('customer_id')).to all(eq(customer_id))
    end
  end

  describe "POST /api/v1/orders" do
    subject { post api_v1_orders_path, params: params }

    let(:params) do
      {
        order: {
          customer_id: customer_id,
          product_name: 'Product 1',
          quantity: 1,
          price: 100.0,
          status: 'pending'
        }
      }
    end

    let(:customer_id) { 1 }

    context "when customer exists" do
      before do
        stub_request(:get, "#{service_url}/api/v1/customers/#{customer_id}")
          .to_return(
            status: 200,
            body: { id: customer_id, name: "Test Customer" }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it "creates a new order" do
        expect { subject }.to change(Order, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(json_response).to include(
                                   'customer_id' => customer_id,
                                   'product_name' => 'Product 1'
                                 )
      end
    end

    context "when customer does not exist" do
      before do
        stub_request(:get, "#{service_url}/api/v1/customers/#{customer_id}")
          .to_return(status: 404)
      end

      it "returns not found" do
        subject

        expect(response).to have_http_status(:not_found)
        expect(json_response).to eq({ 'error' => 'Customer not found' })
      end
    end

    context "with invalid parameters" do
      let(:params) do
        {
          order: {
            customer_id: -1,
            price: -100
          }
        }
      end

      before do
        stub_request(:get, "#{service_url}/api/v1/customers/-1")
          .to_return(
            status: 200,
            body: { id: -1 }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it "returns unprocessable entity" do
        subject

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response).to have_key('error')
      end
    end
  end
end
