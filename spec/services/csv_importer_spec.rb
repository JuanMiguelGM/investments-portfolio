# frozen_string_literal: true

require "rails_helper"

RSpec.describe CsvImporter do
  let(:fixture_path) { Rails.root.join("spec/fixtures/files/portfolio.csv").to_s }

  before do
    create(:policy, slug: "fondo-1")
    create(:policy, slug: "fondo-2")
    create(:policy, slug: "pp")
  end

  describe "#call" do
    it "imports policy snapshots from CSV" do
      result = described_class.new(fixture_path).call

      expect(result.success).to be true
      # Row 1 (03/2019): no value for fondo-1, fondo-2, or pp -> 0 snapshots
      # Row 2 (10/2019): fondo-1 + pp have values -> 2 snapshots
      # Row 3 (10/2020): all 3 have values -> 3 snapshots
      expect(result.snapshots_imported).to eq(5)
      expect(PolicySnapshot.count).to eq(5)
    end

    it "imports contributions from CSV" do
      result = described_class.new(fixture_path).call

      # Row 1: fondo-1 (15000), pp (500) -> 2
      # Row 2: pp (500) -> 1
      # Row 3: fondo-2 (1500), pp (75) -> 2
      expect(result.contributions_imported).to eq(5)
      expect(Contribution.count).to eq(5)
    end

    it "parses European number format correctly" do
      described_class.new(fixture_path).call

      snapshot = PolicySnapshot.joins(:policy).where(policies: { slug: "fondo-1" })
                               .find_by(snapshot_date: Date.new(2019, 10, 1))

      expect(snapshot.total_value).to eq(23_503.00)
      expect(snapshot.total_contributed).to eq(23_000.00)
      expect(snapshot.total_delta).to eq(503.00)
      expect(snapshot.monthly_change).to eq(503.00)
    end

    it "parses MM/YYYY dates correctly" do
      described_class.new(fixture_path).call

      dates = PolicySnapshot.joins(:policy).where(policies: { slug: "fondo-1" })
                            .pluck(:snapshot_date).sort

      expect(dates).to eq([Date.new(2019, 10, 1), Date.new(2020, 10, 1)])
    end

    it "is idempotent" do
      2.times { described_class.new(fixture_path).call }

      expect(PolicySnapshot.count).to eq(5)
      expect(Contribution.count).to eq(5)
    end

    it "returns errors for missing file" do
      result = described_class.new("/nonexistent/file.csv").call

      expect(result.success).to be false
      expect(result.errors).to include(/File not found/)
    end

    it "reports unknown policies as errors" do
      Policy.find_by(slug: "fondo-2").destroy

      result = described_class.new(fixture_path).call

      expect(result.errors).to include(/Policy not found: fondo-2/)
    end
  end
end
