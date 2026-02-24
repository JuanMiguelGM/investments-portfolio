# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Contributions" do
  describe "GET /contributions/new" do
    it "shows the new contribution form" do
      create(:policy)

      get new_contribution_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Record Contribution")
    end
  end

  describe "POST /contributions" do
    it "creates a new contribution" do
      policy = create(:policy)

      post contributions_path, params: {
        contribution: { policy_id: policy.id, contribution_date: "2024-01-01", amount: "500.00" }
      }

      expect(response).to redirect_to(policy_path(policy.slug))
      expect(Contribution.count).to eq(1)
    end

    it "re-renders form on validation error" do
      policy = create(:policy)

      post contributions_path, params: {
        contribution: { policy_id: policy.id, contribution_date: "", amount: "" }
      }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
