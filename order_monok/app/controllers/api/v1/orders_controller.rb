module Api
  module V1
    class OrdersController < ApplicationController
      def index
        orders = Order.by_customer(params[:customer_id])
        render json: orders
      end

      def create
      end

      private

      def order_params
        params.require(:order).permit(:customer_id, :product_name, :quantity, :price, :status)
      end
    end
  end
end
