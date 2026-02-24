# frozen_string_literal: true

require "rails_helper"

RSpec.describe Portfolio::ValueCalculator do
  let(:policy) { create(:policy) }
  let(:fund1) { create(:fund) }
  let(:fund2) { create(:fund) }

  before do
    create(:fund_nav_price, fund: fund1, price_date: Date.current, nav: 100, previous_close: 98)
    create(:fund_nav_price, fund: fund2, price_date: Date.current, nav: 200, previous_close: 195)
    create(:holding, fund: fund1, policy: policy, units: 10)
    create(:holding, fund: fund2, policy: policy, units: 5)
    create(:contribution, policy: policy, amount: 1500, contribution_date: 1.year.ago)
  end

  describe "live data path (holdings with units)" do
    subject(:calculator) { described_class.new }

    describe "#current_value" do
      it "sums holdings × latest NAV across all policies" do
        expect(calculator.current_value).to eq(2000) # 10×100 + 5×200
      end
    end

    describe "#total_gain" do
      it "returns current_value minus total_contributed" do
        expect(calculator.total_gain).to eq(500)
      end
    end

    describe "#total_gain_pct" do
      it "returns percentage gain" do
        expect(calculator.total_gain_pct).to eq(33.33)
      end
    end

    describe "#daily_change" do
      it "sums daily nav changes × units" do
        # fund1: (100-98)×10 = 20, fund2: (200-195)×5 = 25
        expect(calculator.daily_change).to eq(45)
      end
    end

    describe "#daily_change_pct" do
      it "returns daily change as percentage of current value" do
        expect(calculator.daily_change_pct).to eq(2.25)
      end
    end
  end

  describe "snapshot fallback path (no live holdings)" do
    subject(:calculator) { described_class.new(policy: policy) }

    before do
      Holding.find_each { |h| h.update!(units: 0) }
      create(:policy_snapshot, policy: policy, total_value: 3000, total_contributed: 2500, snapshot_date: Date.current)
    end

    describe "#current_value" do
      it "uses latest snapshot total_value when no live holdings" do
        expect(calculator.current_value).to eq(3000)
      end
    end

    describe "#total_contributed" do
      it "uses latest snapshot total_contributed when available" do
        expect(calculator.total_contributed).to eq(2500)
      end
    end

    describe "#total_gain" do
      it "returns snapshot value minus snapshot contributed" do
        expect(calculator.total_gain).to eq(500)
      end
    end
  end

  describe "policy-scoped (live data)" do
    subject(:calculator) { described_class.new(policy: policy) }

    describe "#current_value" do
      it "sums only holdings for the given policy" do
        other_policy = create(:policy)
        other_fund = create(:fund)
        create(:fund_nav_price, fund: other_fund, nav: 999)
        create(:holding, fund: other_fund, policy: other_policy, units: 100)

        expect(calculator.current_value).to eq(2000)
      end
    end
  end

  describe "#annualized_return" do
    it "returns 0 when no contributions exist" do
      Contribution.destroy_all
      calculator = described_class.new
      expect(calculator.annualized_return).to eq(0)
    end
  end
end
