# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Messaging::ConsumerConnection do
  describe '.start' do
    let(:queue_name) { 'test.queue' }
    let(:queue) { instance_double('Bunny::Queue') }
    let(:channel) { instance_double('Bunny::Channel') }
    let(:connection) { instance_double('Bunny::Session') }

    before do
      allow(ENV).to receive(:fetch).with("RABBIT_HOST", "localhost").and_return("localhost")
      allow(ENV).to receive(:fetch).with("RABBIT_PORT", 5672).and_return(5672)
      allow(ENV).to receive(:fetch).with("RABBIT_VHOST", "/").and_return("/")
      allow(ENV).to receive(:fetch).with("RABBIT_USER", "guest").and_return("guest")
      allow(ENV).to receive(:fetch).with("RABBIT_PASSWORD", "guest").and_return("guest")

      allow(Bunny).to receive(:new).and_return(connection)
      allow(connection).to receive(:start)
      allow(connection).to receive(:create_channel).and_return(channel)
      allow(channel).to receive(:queue).with(queue_name).and_return(queue)
    end

    it 'returns a configured queue' do
      expect(described_class.start(queue_name)).to eq(queue)
    end

    it 'configures queue with the correct name' do
      expect(channel).to receive(:queue).with(queue_name)
      described_class.start(queue_name)
    end

    it 'uses correct connection parameters' do
      expect(Bunny).to receive(:new).with({
                                            host: "localhost",
                                            port: 5672,
                                            vhost: "/",
                                            username: "guest",
                                            password: "guest"
                                          })
      described_class.start(queue_name)
    end

    context 'when there is an error' do
      before do
        allow(channel).to receive(:queue).and_raise(StandardError.new('Connection failed'))
      end

      it 'raises ConsumptionError' do
        expect {
          described_class.start(queue_name)
        }.to raise_error(Messaging::ConsumerConnection::ConsumptionError, /Failed to consume message/)
      end
    end
  end
end
