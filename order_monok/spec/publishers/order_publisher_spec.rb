# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OrderPublisher do
  describe '.order_created' do
    let(:order) { create(:order) }
    let(:expected_payload) do
      {
        id: order.id,
        customer_id: order.customer_id,
        status: order.status,
        updated_at: order.updated_at
      }
    end

    let(:exchange) { instance_double(Bunny::Exchange) }
    let(:channel) { instance_double(Bunny::Channel) }
    let(:connection) { instance_double(Bunny::Session) }

    before do
      allow(Bunny).to receive(:new).and_return(connection)
      allow(connection).to receive(:start)
      allow(connection).to receive(:create_channel).and_return(channel)
      allow(channel).to receive(:default_exchange).and_return(exchange)
      allow(channel).to receive(:open?).and_return(true)
      allow(channel).to receive(:close)
      allow(exchange).to receive(:publish)
    end

    it 'publishes order created event with correct parameters' do
      expect(exchange).to receive(:publish).with(
        expected_payload.to_json,
        routing_key: "orders.created",
        persistent: true,
        content_type: "application/json"
      )

      described_class.order_created(order)
    end
  end
end
