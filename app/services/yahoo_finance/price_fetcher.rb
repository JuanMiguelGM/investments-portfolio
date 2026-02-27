# frozen_string_literal: true

module YahooFinance
  class PriceFetcher
    Result = Struct.new(:success, :prices_upserted, :errors)

    def initialize(client: Client.new)
      @client = client
      @errors = []
      @upserted = 0
    end

    def call
      Fund.auto_fetch.find_each do |fund|
        fetch_and_upsert(fund)
      end

      Result.new(success: @errors.empty?, prices_upserted: @upserted, errors: @errors)
    end

    private

    def fetch_and_upsert(fund)
      result = fetch_chart_result(fund)
      return unless result

      process_price_data(fund, result)
    rescue Faraday::Error => e
      @errors << "HTTP error for #{fund.yahoo_ticker}: #{e.message}"
    rescue JSON::ParserError => e
      @errors << "Parse error for #{fund.yahoo_ticker}: #{e.message}"
    end

    def fetch_chart_result(fund)
      data = @client.fetch_chart(fund.yahoo_ticker)
      result = data.dig("chart", "result")&.first
      @errors << "No data for #{fund.yahoo_ticker}" unless result
      result
    end

    def process_price_data(fund, result)
      timestamps = result["timestamp"] || []
      closes = result.dig("indicators", "quote", 0, "close") || []
      previous_close = result.dig("meta", "chartPreviousClose").then { |v| v&.positive? ? v : nil }

      if timestamps.empty?
        process_meta_price(fund, result, previous_close)
      else
        process_timeseries(fund, timestamps, closes, previous_close)
      end
    end

    def process_meta_price(fund, result, previous_close)
      nav = result.dig("meta", "regularMarketPrice")
      return unless nav

      price_date = Time.zone.at(result.dig("meta", "regularMarketTime")).to_date
      upsert_price(fund, price_date, nav, previous_close)
    end

    def process_timeseries(fund, timestamps, closes, previous_close)
      timestamps.zip(closes).each_with_index do |(ts, close), index|
        next unless ts && close

        price_date = Time.zone.at(ts).to_date
        prev = index.zero? ? previous_close : closes[index - 1]

        upsert_price(fund, price_date, close, prev)
      end
    end

    def upsert_price(fund, price_date, nav, previous_close)
      price = FundNavPrice.find_or_initialize_by(fund: fund, price_date: price_date)
      price.update!(nav: nav, previous_close: previous_close)
      @upserted += 1
    rescue ActiveRecord::RecordInvalid => e
      @errors << "Save error for #{fund.yahoo_ticker} on #{price_date}: #{e.message}"
    end
  end
end
