# frozen_string_literal: true

require "rails_helper"

RSpec.describe Portfolio::ReturnsCalculator do
  let(:policy) { create(:policy) }
  let(:fund) { create(:fund) }

  before do
    create(:holding, fund: fund, policy: policy, units: 10)
    create(:policy_snapshot, policy: policy, snapshot_date: Date.new(2023, 6, 1), total_value: 5000)
    create(:policy_snapshot, policy: policy, snapshot_date: Date.new(2023, 7, 1), total_value: 5200)
    create(:fund_nav_price, fund: fund, price_date: 2.days.ago, nav: 150)
    create(:fund_nav_price, fund: fund, price_date: 1.day.ago, nav: 152)
  end

  describe "#chart_data" do
    it "returns a hash of date => value pairs" do
      calculator = described_class.new
      data = calculator.chart_data(period: "ALL")

      expect(data).to be_a(Hash)
      expect(data.keys).to all(be_a(Date))
      expect(data.values).to all(be_a(Float))
    end

    it "includes both snapshot and live data" do
      calculator = described_class.new
      data = calculator.chart_data(period: "ALL")

      expect(data[Date.new(2023, 6, 1)]).to eq(5000.0)
      expect(data).to have_key(1.day.ago.to_date)
    end

    it "respects period filter" do
      calculator = described_class.new
      data = calculator.chart_data(period: "1M")

      expect(data).not_to have_key(Date.new(2023, 6, 1))
    end
  end

  describe "#policy_chart_data" do
    it "returns chart data for a specific policy" do
      calculator = described_class.new
      data = calculator.policy_chart_data(policy, period: "ALL")

      expect(data).to be_a(Hash)
      expect(data[Date.new(2023, 6, 1)]).to eq(5000.0)
    end
  end

  describe "#fund_chart_data" do
    it "returns an array of series hashes" do
      calculator = described_class.new
      series = calculator.fund_chart_data(period: "ALL")

      expect(series).to be_an(Array)
      expect(series.first).to include(:name, :data)
    end

    it "computes value as units times NAV for each date" do
      calculator = described_class.new
      series = calculator.fund_chart_data(period: "ALL")

      fund_series = series.find { |s| s[:name] == fund.name }
      expect(fund_series[:data][1.day.ago.to_date]).to be_within(0.01).of(10 * 152.0)
    end

    it "excludes funds with no NAV prices" do
      fund_no_prices = create(:fund)
      create(:holding, fund: fund_no_prices, policy: policy, units: 5)

      calculator = described_class.new
      series = calculator.fund_chart_data(period: "ALL")

      names = series.filter_map { |s| s[:name] }
      expect(names).not_to include(fund_no_prices.name)
    end

    it "returns empty array when no holdings with units exist" do
      Holding.destroy_all

      calculator = described_class.new
      expect(calculator.fund_chart_data(period: "ALL")).to eq([])
    end
  end
end
