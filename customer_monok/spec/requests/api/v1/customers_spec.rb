# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Api::V1::Customers", type: :request do
  describe "GET /api/v1/customers/:id" do
    context "when customer exists" do
      let!(:customer) { create(:customer) }

      before { get api_v1_customer_path(customer.id) }

      it "returns status code 200" do
        expect(response).to have_http_status(:ok)
      end

      it "returns customer data" do
        expect(json_response).to include(
                                   'id' => customer.id,
                                   'name' => customer.name,
                                   'email' => customer.email,
                                   'address' => customer.address,
                                   'orders_count' => customer.orders_count
                                 )
      end
    end

    context "when customer does not exist" do
      before { get api_v1_customer_path(999) }

      it "returns status code 404" do
        expect(response).to have_http_status(:not_found)
      end

      it "returns error message" do
        expect(json_response).to include('error' => 'Customer not found')
      end
    end
  end
end
