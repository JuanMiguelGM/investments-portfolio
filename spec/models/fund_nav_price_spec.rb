# frozen_string_literal: true

require "rails_helper"

RSpec.describe FundNavPrice do
  describe "validations" do
    subject { build(:fund_nav_price) }

    it { is_expected.to validate_presence_of(:price_date) }
    it { is_expected.to validate_uniqueness_of(:price_date).scoped_to(:fund_id) }
    it { is_expected.to validate_presence_of(:nav) }
    it { is_expected.to validate_numericality_of(:nav).is_greater_than(0) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:fund) }
  end

  describe "#daily_change" do
    it "returns the difference between nav and previous_close" do
      price = build(:fund_nav_price, nav: 105.00, previous_close: 100.00)
      expect(price.daily_change).to eq(5.00)
    end

    it "returns nil when previous_close is nil" do
      price = build(:fund_nav_price, previous_close: nil)
      expect(price.daily_change).to be_nil
    end
  end

  describe "#daily_change_pct" do
    it "returns the percentage change" do
      price = build(:fund_nav_price, nav: 105.00, previous_close: 100.00)
      expect(price.daily_change_pct).to eq(5.00)
    end

    it "returns nil when previous_close is nil" do
      price = build(:fund_nav_price, previous_close: nil)
      expect(price.daily_change_pct).to be_nil
    end
  end

  describe ".for_period" do
    it "returns prices within date range" do
      fund = create(:fund)
      create(:fund_nav_price, fund: fund, price_date: 10.days.ago)
      create(:fund_nav_price, fund: fund, price_date: 5.days.ago)
      create(:fund_nav_price, fund: fund, price_date: 1.day.ago)

      result = described_class.for_period(7.days.ago, Date.current)
      expect(result.count).to eq(2)
    end
  end
end
