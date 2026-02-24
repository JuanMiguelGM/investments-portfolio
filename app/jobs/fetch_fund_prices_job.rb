# frozen_string_literal: true

class FetchFundPricesJob < ApplicationJob
  queue_as :default

  def perform
    result = YahooFinance::PriceFetcher.new.call

    Rails.logger.warn("FetchFundPricesJob errors: #{result.errors.join(", ")}") if result.errors.any?

    Rails.logger.info("FetchFundPricesJob: upserted #{result.prices_upserted} prices")
  end
end
