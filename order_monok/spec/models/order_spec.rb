# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Order, type: :model do
  describe 'validations' do
    subject(:order) { build(:order) }

    it { should validate_presence_of(:customer_id) }
    it { should validate_presence_of(:product_name) }
    it { should validate_presence_of(:quantity) }
    it { should validate_presence_of(:price) }
    it { should validate_presence_of(:status) }

    it { should validate_numericality_of(:customer_id).only_integer.is_greater_than(0) }
    it { should validate_numericality_of(:quantity).only_integer.is_greater_than(0) }
    it { should validate_numericality_of(:price).is_greater_than(0) }
  end

  describe 'enums' do
    it { should define_enum_for(:status).with_values(
      pending: "pending",
      processing: "processing",
      completed: "completed",
      cancelled: "cancelled"
    ).backed_by_column_of_type(:string)
    }
  end

  describe 'scopes' do
    describe '.by_customer' do
      let!(:order1) { create(:order, customer_id: 1) }
      let!(:order2) { create(:order, customer_id: 2) }

      it 'returns orders for specific customer' do
        expect(Order.by_customer(1)).to include(order1)
        expect(Order.by_customer(1)).not_to include(order2)
      end
    end
  end

  describe 'callbacks' do
    describe 'after_commit on create' do
      let(:order) { build(:order) }

      it 'publishes order created event' do
        expect(OrderPublisher).to receive(:order_created).with(order)
        order.save!
      end

      it 'does not publish on update' do
        order.save!
        expect(OrderPublisher).not_to receive(:order_created)
        order.update!(quantity: 2)
      end

      it 'does not publish when record is invalid' do
        order.price = -1
        expect(OrderPublisher).not_to receive(:order_created)
        expect { order.save! }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end
