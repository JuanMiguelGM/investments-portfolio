# frozen_string_literal: true

require "rails_helper"

RSpec.describe Holding do
  describe "validations" do
    subject { build(:holding) }

    it { is_expected.to validate_numericality_of(:units).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_uniqueness_of(:fund_id).scoped_to(:policy_id) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:fund) }
    it { is_expected.to belong_to(:policy) }
  end

  describe "#current_value" do
    let(:fund) { create(:fund) }
    let(:policy) { create(:policy) }

    it "calculates units times latest NAV" do
      create(:fund_nav_price, fund: fund, nav: 150.00)
      holding = create(:holding, fund: fund, policy: policy, units: 10)

      expect(holding.current_value).to eq(1500.00)
    end

    it "returns 0 when no NAV exists" do
      holding = create(:holding, fund: fund, policy: policy, units: 10)
      expect(holding.current_value).to eq(0)
    end

    it "returns 0 when units are zero" do
      create(:fund_nav_price, fund: fund, nav: 150.00)
      holding = create(:holding, fund: fund, policy: policy, units: 0)

      expect(holding.current_value).to eq(0)
    end
  end

  describe ".with_units" do
    it "returns only holdings with positive units" do
      create(:holding, units: 10)
      create(:holding, units: 0)

      expect(described_class.with_units.count).to eq(1)
    end
  end
end
