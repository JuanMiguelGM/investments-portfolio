# frozen_string_literal: true

module YahooFinance
  class Client
    BASE_URL = "https://query1.finance.yahoo.com"

    def initialize
      @connection = Faraday.new(url: BASE_URL) do |f|
        f.request :retry, max: 2, interval: 0.5
        f.response :raise_error
        f.adapter Faraday.default_adapter
      end
    end

    def fetch_chart(ticker, range: "5d", interval: "1d")
      cache_key = "yahoo_finance/#{ticker}/#{Date.current}/#{range}/#{interval}"

      Rails.cache.fetch(cache_key, expires_in: 6.hours) do
        response = @connection.get("/v8/finance/chart/#{ticker}") do |req|
          req.params["range"] = range
          req.params["interval"] = interval
          req.params["includePrePost"] = false
        end

        JSON.parse(response.body)
      end
    end
  end
end
