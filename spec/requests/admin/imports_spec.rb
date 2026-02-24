# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Imports" do
  describe "POST /admin/import" do
    it "imports CSV and redirects" do
      create(:policy, slug: "fondo-1")
      create(:policy, slug: "fondo-2")
      create(:policy, slug: "pp")

      fixture_path = Rails.root.join("spec/fixtures/files/portfolio.csv")
      import_path_dir = Rails.root.join("tmp/imports")
      FileUtils.mkdir_p(import_path_dir)
      FileUtils.cp(fixture_path, import_path_dir.join("portfolio.csv"))

      post admin_import_path

      expect(response).to redirect_to(root_path)
      follow_redirect!
      expect(response.body).to include("Imported")
    end
  end
end
