# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Prices" do
  describe "POST /admin/prices" do
    it "fetches prices and redirects" do
      result = YahooFinance::PriceFetcher::Result.new(success: true, prices_upserted: 9, errors: [])
      fetcher = instance_double(YahooFinance::PriceFetcher, call: result)
      allow(YahooFinance::PriceFetcher).to receive(:new).and_return(fetcher)

      post admin_prices_path

      expect(response).to redirect_to(root_path)
    end
  end
end
