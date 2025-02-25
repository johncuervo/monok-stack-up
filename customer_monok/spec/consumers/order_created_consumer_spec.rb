# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OrderCreatedConsumer do
  describe '.start' do
    let(:queue_name) { 'orders.created' }
    let(:queue) { instance_double('Bunny::Queue') }
    let(:event_data) { { "id" => 1, "customer_id" => customer_id }.to_json }
    let(:delivery_info) { double('delivery_info') }
    let(:properties) { double('properties') }

    before do
      allow(Messaging::ConsumerConnection).to receive(:start)
                                                .with(queue_name)
                                                .and_return(queue)
      allow(described_class).to receive(:puts)
    end

    it 'subscribes to the orders.created queue' do
      expect(queue).to receive(:subscribe).with(block: true)
      described_class.start
    end

    context 'when message is processed' do
      let!(:customer) { create(:customer, orders_count: 5) }
      let(:customer_id) { customer.id }

      before do
        allow(queue).to receive(:subscribe) do |&block|
          block.call(delivery_info, properties, event_data)
        end
      end

      it 'increments the customer orders_count' do
        expect {
          described_class.start
        }.to change { customer.reload.orders_count }.by(1)
      end
    end

    context 'when customer does not exist' do
      let(:customer_id) { 999 }

      before do
        allow(queue).to receive(:subscribe) do |&block|
          block.call(delivery_info, properties, event_data)
        end
      end

      it 'does not raise error' do
        expect {
          described_class.start
        }.not_to raise_error
      end
    end

    context 'when JSON parsing fails' do
      let(:invalid_json) { '{invalid_json: "data"' }

      before do
        allow(queue).to receive(:subscribe) do |&block|
          block.call(delivery_info, properties, invalid_json)
        end
        allow(JSON).to receive(:parse).and_raise(JSON::ParserError.new("unexpected token"))
        allow(Rails.logger).to receive(:info)
      end

      it 'logs the parsing error' do
        expect(Rails.logger).to receive(:info).with(/Failed to parse message/)
        described_class.start
      end

      it 'does not raise error' do
        expect {
          described_class.start
        }.not_to raise_error
      end
    end
  end
end
