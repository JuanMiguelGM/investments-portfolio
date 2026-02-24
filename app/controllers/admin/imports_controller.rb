# frozen_string_literal: true

module Admin
  class ImportsController < ApplicationController
    def create
      file_path = Rails.root.join("tmp/imports/portfolio.csv").to_s
      result = CsvImporter.new(file_path).call

      if result.success
        msg = "Imported #{result.snapshots_imported} snapshots and #{result.contributions_imported} contributions"
        redirect_to root_path, notice: msg
      else
        redirect_to root_path, alert: "Import errors: #{result.errors.join(", ")}"
      end
    end
  end
end
