# frozen_string_literal: true

require "rails_helper"

RSpec.describe Fund do
  describe "validations" do
    subject { build(:fund) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:isin) }
    it { is_expected.to validate_uniqueness_of(:isin) }

    it {
      expect(subject).to validate_numericality_of(:allocation_pct)
        .is_greater_than_or_equal_to(0)
        .is_less_than_or_equal_to(100)
    }
  end

  describe ".auto_fetch" do
    it "includes funds with a yahoo_ticker" do
      with_ticker = create(:fund, yahoo_ticker: "TICK.IR")
      without_ticker = create(:fund, yahoo_ticker: nil)

      expect(described_class.auto_fetch).to include(with_ticker)
      expect(described_class.auto_fetch).not_to include(without_ticker)
    end
  end

  describe "associations" do
    it { is_expected.to have_many(:holdings).dependent(:destroy) }
    it { is_expected.to have_many(:policies).through(:holdings) }
    it { is_expected.to have_many(:fund_nav_prices).dependent(:destroy) }
  end

  describe "#latest_nav" do
    let(:fund) { create(:fund) }

    it "returns the most recent nav price" do
      create(:fund_nav_price, fund: fund, price_date: 2.days.ago, nav: 100)
      recent = create(:fund_nav_price, fund: fund, price_date: Date.current, nav: 105)

      expect(fund.latest_nav).to eq(recent)
    end

    it "returns nil when no prices exist" do
      expect(fund.latest_nav).to be_nil
    end
  end

  describe "#latest_nav_value" do
    let(:fund) { create(:fund) }

    it "returns the nav decimal from the latest price" do
      create(:fund_nav_price, fund: fund, price_date: Date.current, nav: 105.50)
      expect(fund.latest_nav_value).to eq(105.50)
    end

    it "returns nil when no prices exist" do
      expect(fund.latest_nav_value).to be_nil
    end
  end
end
