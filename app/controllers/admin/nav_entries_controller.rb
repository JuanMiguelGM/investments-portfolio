# frozen_string_literal: true

module Admin
  class NavEntriesController < ApplicationController
    def new
      @funds = Fund.where(yahoo_ticker: nil).ordered
      @nav_entry = FundNavPrice.new(price_date: Date.current)
    end

    def create
      fund = Fund.find(nav_entry_params[:fund_id])
      price = FundNavPrice.find_or_initialize_by(fund: fund, price_date: nav_entry_params[:price_date])

      if price.update(nav: nav_entry_params[:nav], previous_close: price.nav_was)
        redirect_to root_path, notice: "NAV saved for #{fund.name}"
      else
        @funds = Fund.where(yahoo_ticker: nil).ordered
        @nav_entry = price
        render :new, status: :unprocessable_content
      end
    end

    private

    def nav_entry_params
      params.expect(nav_entry: %i[fund_id price_date nav])
    end
  end
end
