class OrderCreator
  def initialize(order_params)
    @order_params = order_params
  end

  def self.create(order_params)
    new(order_params).create
  end

  def create
    validate_customer
    create_order
  end

  private

  def validate_customer
    @customer_data = CustomerService.get_customer(@order_params[:customer_id].to_i)
  end

  def create_order
    Order.create!(@order_params)
  end
end
