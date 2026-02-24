# frozen_string_literal: true

class FundsController < ApplicationController
  def index
    @funds = Fund.ordered.includes(:fund_nav_prices)
  end

  def show
    @fund = Fund.find(params[:id])
    @period = params[:period] || "1Y"
    start_date = period_start_date(@period)
    @nav_data = @fund.fund_nav_prices.where(price_date: start_date..).chronological
                     .pluck(:price_date, :nav)
                     .map { |date, nav| [date.strftime("%d/%m/%Y"), nav.to_f] }
    @holdings = @fund.holdings.includes(:policy).with_units
  end

  private

  def period_start_date(period)
    case period
    when "1M" then 1.month.ago.to_date
    when "3M" then 3.months.ago.to_date
    when "6M" then 6.months.ago.to_date
    when "YTD" then Date.current.beginning_of_year
    when "1Y" then 1.year.ago.to_date
    when "3Y" then 3.years.ago.to_date
    else Date.new(2019, 3, 1)
    end
  end
end
