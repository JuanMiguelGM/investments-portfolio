# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Policies" do
  describe "GET /policies/:slug" do
    it "shows policy details" do
      policy = create(:policy, name: "Medvida 1", slug: "medvida-1")

      get policy_path(policy.slug)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Medvida 1")
    end
  end
end
