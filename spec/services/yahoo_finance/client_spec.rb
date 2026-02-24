# frozen_string_literal: true

require "rails_helper"

RSpec.describe YahooFinance::Client do
  describe "#fetch_chart" do
    let(:client) { described_class.new }
    let(:ticker) { "IE0032126645.IR" }

    it "returns parsed JSON from Yahoo Finance" do
      body = { "chart" => { "result" => [{ "meta" => {} }] } }.to_json

      stub_request(:get, "https://query1.finance.yahoo.com/v8/finance/chart/#{ticker}")
        .with(query: hash_including("range" => "5d"))
        .to_return(status: 200, body: body, headers: { "Content-Type" => "application/json" })

      result = client.fetch_chart(ticker)
      expect(result.dig("chart", "result")).to be_an(Array)
    end

    it "raises on HTTP errors" do
      stub_request(:get, "https://query1.finance.yahoo.com/v8/finance/chart/#{ticker}")
        .with(query: hash_including("range" => "5d"))
        .to_return(status: 500, body: "", headers: {})

      expect { client.fetch_chart(ticker) }.to raise_error(Faraday::ServerError)
    end

    it "caches the response for the same ticker and date" do
      body = { "chart" => { "result" => [{ "meta" => {} }] } }.to_json

      stub = stub_request(:get, "https://query1.finance.yahoo.com/v8/finance/chart/#{ticker}")
             .with(query: hash_including("range" => "5d"))
             .to_return(status: 200, body: body, headers: { "Content-Type" => "application/json" })

      with_memory_cache { 2.times { described_class.new.fetch_chart(ticker) } }

      expect(stub).to have_been_requested.once
    end
  end
end
