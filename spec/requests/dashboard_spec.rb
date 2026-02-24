# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Dashboard" do
  describe "GET /" do
    it "renders the dashboard" do
      get root_path
      expect(response).to have_http_status(:ok)
    end

    it "shows onboarding when no data exists" do
      get root_path
      expect(response.body).to include("Welcome to your Portfolio Dashboard")
    end

    it "shows metrics when data exists" do
      policy = create(:policy)
      create(:policy_snapshot, policy: policy)

      get root_path
      expect(response.body).to include("Total Value")
    end

    it "accepts period parameter" do
      get root_path, params: { period: "1Y" }
      expect(response).to have_http_status(:ok)
    end

    context "with pending monthly contribution" do
      it "shows the pending contributions banner when this month has no contribution" do
        policy = create(:policy)
        create(:contribution, policy: policy, contribution_date: 1.month.ago.beginning_of_month, amount: 1000)

        get root_path
        expect(response.body).to include("Pending Contributions")
        expect(response.body).to include("1.000,00")
      end

      it "does not show the banner when this month already has a contribution" do
        policy = create(:policy)
        create(:contribution, policy: policy, contribution_date: Date.current.beginning_of_month, amount: 1000)

        get root_path
        expect(response.body).not_to include("Pending Contributions")
      end

      it "does not show the banner when the policy has no contribution history" do
        create(:policy)

        get root_path
        expect(response.body).not_to include("Pending Contributions")
      end
    end
  end
end
