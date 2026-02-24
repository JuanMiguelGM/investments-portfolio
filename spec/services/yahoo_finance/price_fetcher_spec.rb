# frozen_string_literal: true

require "rails_helper"

RSpec.describe YahooFinance::PriceFetcher do
  let(:client) { instance_double(YahooFinance::Client) }
  let(:fetcher) { described_class.new(client: client) }

  let!(:fund) { create(:fund, yahoo_ticker: "IE0032126645.IR") }

  let(:yahoo_response) do
    {
      "chart" => {
        "result" => [{
          "meta" => { "chartPreviousClose" => 148.50 },
          "timestamp" => [1_708_300_800, 1_708_387_200],
          "indicators" => {
            "quote" => [{
              "close" => [150.25, 151.00]
            }]
          }
        }]
      }
    }
  end

  describe "#call" do
    it "upserts fund nav prices from Yahoo data" do
      allow(client).to receive(:fetch_chart).and_return(yahoo_response)

      result = fetcher.call

      expect(result.success).to be true
      expect(result.prices_upserted).to eq(2)
      expect(FundNavPrice.count).to eq(2)
    end

    it "sets previous_close correctly" do
      allow(client).to receive(:fetch_chart).and_return(yahoo_response)

      fetcher.call

      prices = FundNavPrice.where(fund: fund).order(:price_date)
      expect(prices.first.previous_close).to eq(148.50)
      expect(prices.last.previous_close).to eq(150.25)
    end

    it "handles HTTP errors gracefully" do
      allow(client).to receive(:fetch_chart).and_raise(Faraday::ConnectionFailed, "timeout")

      result = fetcher.call

      expect(result.success).to be false
      expect(result.errors).to include(/HTTP error/)
    end

    it "handles missing data gracefully" do
      allow(client).to receive(:fetch_chart).and_return({ "chart" => { "result" => nil } })

      result = fetcher.call

      expect(result.success).to be false
      expect(result.errors).to include(/No data/)
    end

    it "is idempotent" do
      allow(client).to receive(:fetch_chart).and_return(yahoo_response)

      2.times { described_class.new(client: client).call }

      expect(FundNavPrice.count).to eq(2)
    end

    it "skips funds without a yahoo_ticker" do
      create(:fund, yahoo_ticker: nil)
      allow(client).to receive(:fetch_chart).and_return(yahoo_response)

      result = fetcher.call

      expect(client).to have_received(:fetch_chart).once
      expect(result.prices_upserted).to eq(2)
    end

    context "when timestamps are empty (meta-only funds)" do
      let(:meta_only_response) do
        {
          "chart" => {
            "result" => [{
              "meta" => { "regularMarketPrice" => 20.18, "regularMarketTime" => 1_668_186_015,
                          "chartPreviousClose" => nil },
              "timestamp" => [],
              "indicators" => { "quote" => [{ "close" => [] }] }
            }]
          }
        }
      end

      it "falls back to meta price" do
        allow(client).to receive(:fetch_chart).and_return(meta_only_response)
        fetcher.call
        expect(FundNavPrice.count).to eq(1)
        expect(FundNavPrice.first.nav).to eq(20.18)
        expect(FundNavPrice.first.previous_close).to be_nil
      end
    end
  end
end
