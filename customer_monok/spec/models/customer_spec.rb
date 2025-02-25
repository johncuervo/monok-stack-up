# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Customer, type: :model do
  describe 'validations' do
    subject { build(:customer) }

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:address) }
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email) }
    it { should allow_value('user@example.com').for(:email) }
    it { should_not allow_value('invalid_email').for(:email) }
    it { should_not allow_value('user@').for(:email) }
    it { should_not allow_value('@example.com').for(:email) }
    it { should validate_numericality_of(:orders_count).only_integer.is_greater_than_or_equal_to(0) }
  end
end
