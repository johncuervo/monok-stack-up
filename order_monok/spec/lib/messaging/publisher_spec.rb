# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Messaging::Publisher do
  describe '.publish' do
    let(:payload) { { test: 'data' } }
    let(:routing_key) { 'test.event' }

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

    it 'publishes message with correct parameters' do
      expect(exchange).to receive(:publish).with(
        payload.to_json,
        routing_key: routing_key,
        persistent: true,
        content_type: 'application/json'
      )

      described_class.publish(payload, routing_key: routing_key)
    end

    it 'closes the channel after publishing' do
      expect(channel).to receive(:close)
      described_class.publish(payload, routing_key: routing_key)
    end

    context 'when RABBIT_HOST is not configured' do
      before do
        allow(ENV).to receive(:fetch).with('RABBIT_HOST', 'localhost').and_return('localhost')
        allow(ENV).to receive(:fetch).with('RABBIT_PORT', 5672).and_return(5672)
        allow(ENV).to receive(:fetch).with('RABBIT_VHOST', '/').and_return('/')
        allow(ENV).to receive(:fetch).with('RABBIT_USERNAME', 'guest').and_return('guest')
        allow(ENV).to receive(:fetch).with('RABBIT_PASSWORD', 'guest').and_return('guest')
      end

      it 'uses default configuration' do
        expect(Bunny).to receive(:new).with(
          hash_including(
            host: 'localhost',
            port: 5672,
            vhost: '/',
            username: 'guest',
            password: 'guest'
          )
        ).and_return(connection)

        described_class.publish(payload, routing_key: routing_key)
      end
    end
  end
end
