# frozen_string_literal: true

module Api
  module V1
# CustomersController handles retrieving customer information by ID, returning JSON data or an error if not found.
class CustomersController < ApplicationController
      def show
        customer = Customer.find(params[:id])
        render json: customer
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Customer not found" }, status: :not_found
      end
end
  end
end
