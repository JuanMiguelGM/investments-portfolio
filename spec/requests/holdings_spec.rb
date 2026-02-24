# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Holdings" do
  let(:policy) { create(:policy) }

  describe "GET /holdings/:id/edit" do
    it "shows the holdings edit form" do
      create(:fund)

      get edit_holding_path(policy)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Edit Holdings")
    end
  end

  describe "PATCH /holdings/:id" do
    it "updates holdings for a policy" do
      fund = create(:fund)

      patch holding_path(policy), params: {
        holdings: [{ fund_id: fund.id, units: "123.456" }]
      }

      expect(response).to redirect_to(policy_path(policy.slug))
      expect(Holding.find_by(fund: fund, policy: policy).units).to eq(123.456)
    end
  end
end
