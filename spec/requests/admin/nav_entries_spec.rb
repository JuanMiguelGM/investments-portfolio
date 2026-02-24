# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::NavEntries" do
  let!(:fund) { create(:fund, yahoo_ticker: nil) }

  describe "GET /admin/nav_entries/new" do
    it "shows the NAV entry form" do
      get new_admin_nav_entry_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Enter NAV Manually")
      expect(response.body).to include(fund.name)
    end
  end

  describe "POST /admin/nav_entries" do
    it "creates a NAV price and redirects to dashboard" do
      post admin_nav_entries_path, params: {
        nav_entry: { fund_id: fund.id, price_date: Date.current.to_s, nav: "124.5000" }
      }

      expect(response).to redirect_to(root_path)
      expect(FundNavPrice.count).to eq(1)
      expect(FundNavPrice.first.nav).to eq(124.5)
    end

    it "updates an existing NAV price for the same date" do
      create(:fund_nav_price, fund: fund, price_date: Date.current, nav: 120.0)

      post admin_nav_entries_path, params: {
        nav_entry: { fund_id: fund.id, price_date: Date.current.to_s, nav: "125.0000" }
      }

      expect(FundNavPrice.count).to eq(1)
      expect(FundNavPrice.first.nav).to eq(125.0)
    end

    it "re-renders form on validation error" do
      post admin_nav_entries_path, params: {
        nav_entry: { fund_id: fund.id, price_date: "", nav: "" }
      }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
