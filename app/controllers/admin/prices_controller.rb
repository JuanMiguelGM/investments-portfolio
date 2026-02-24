# frozen_string_literal: true

module Admin
  class PricesController < ApplicationController
    def create
      FetchFundPricesJob.perform_now
      redirect_to root_path, notice: "Prices fetched successfully"
    end
  end
end
