module Api
  module V1
    class OrdersController < ApplicationController
      def index
        orders = Order.by_customer(params[:customer_id])
        render json: orders
      end

      def create
        order = ::OrderCreator.create(order_params)
        render json: order, status: :created
      rescue ::CustomerService::CustomerNotFoundError
        render json: { error: "Customer not found" }, status: :not_found
      rescue StandardError => e
        render json: { error: e.message }, status: :unprocessable_entity
      end

      private

      def order_params
        params.require(:order).permit(:customer_id, :product_name, :quantity, :price, :status)
      end
    end
  end
end
