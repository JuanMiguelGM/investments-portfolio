# frozen_string_literal: true

require "rails_helper"

RSpec.describe FetchFundPricesJob do
  it "calls YahooFinance::PriceFetcher" do
    result = YahooFinance::PriceFetcher::Result.new(success: true, prices_upserted: 9, errors: [])
    fetcher = instance_double(YahooFinance::PriceFetcher, call: result)
    allow(YahooFinance::PriceFetcher).to receive(:new).and_return(fetcher)

    described_class.perform_now

    expect(fetcher).to have_received(:call)
  end
end
