# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Funds" do
  describe "GET /funds" do
    it "lists all funds" do
      create(:fund, name: "Vanguard US 500")

      get funds_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Vanguard US 500")
    end
  end

  describe "GET /funds/:id" do
    it "shows fund details" do
      fund = create(:fund, name: "Vanguard US 500")

      get fund_path(fund)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Vanguard US 500")
    end

    it "accepts period parameter" do
      fund = create(:fund)

      get fund_path(fund, period: "3M")
      expect(response).to have_http_status(:ok)
    end
  end
end
