# frozen_string_literal: true

require "rails_helper"

RSpec.describe PolicySnapshot do
  describe "validations" do
    subject { build(:policy_snapshot) }

    it { is_expected.to validate_presence_of(:snapshot_date) }
    it { is_expected.to validate_uniqueness_of(:snapshot_date).scoped_to(:policy_id) }
    it { is_expected.to validate_presence_of(:total_value) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:policy) }
  end

  describe "#gain_pct" do
    it "returns percentage gain" do
      snapshot = build(:policy_snapshot, total_contributed: 10_000, total_delta: 1_000)
      expect(snapshot.gain_pct).to eq(10.00)
    end

    it "returns nil when total_contributed is zero" do
      snapshot = build(:policy_snapshot, total_contributed: 0, total_delta: 0)
      expect(snapshot.gain_pct).to be_nil
    end

    it "returns nil when total_contributed is nil" do
      snapshot = build(:policy_snapshot, total_contributed: nil, total_delta: 1_000)
      expect(snapshot.gain_pct).to be_nil
    end
  end
end
