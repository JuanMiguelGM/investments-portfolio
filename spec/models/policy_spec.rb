# frozen_string_literal: true

require "rails_helper"

RSpec.describe Policy do
  describe "validations" do
    subject { build(:policy) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:slug) }
    it { is_expected.to validate_uniqueness_of(:slug) }
    it { is_expected.to validate_presence_of(:inception_date) }
  end

  describe "associations" do
    it { is_expected.to have_many(:holdings).dependent(:destroy) }
    it { is_expected.to have_many(:funds).through(:holdings) }
    it { is_expected.to have_many(:contributions).dependent(:destroy) }
    it { is_expected.to have_many(:policy_snapshots).dependent(:destroy) }
  end

  describe "#to_param" do
    it "returns the slug" do
      policy = build(:policy, slug: "medvida-1")
      expect(policy.to_param).to eq("medvida-1")
    end
  end

  describe "#total_contributed" do
    let(:policy) { create(:policy) }

    it "sums all contribution amounts" do
      create(:contribution, policy: policy, amount: 500)
      create(:contribution, policy: policy, amount: 300)

      expect(policy.total_contributed).to eq(800)
    end

    it "returns 0 when no contributions" do
      expect(policy.total_contributed).to eq(0)
    end
  end

  describe "policy_type enum" do
    it "defaults to insurance" do
      policy = create(:policy)
      expect(policy).to be_insurance
    end

    it "can be set to pension" do
      policy = create(:policy, policy_type: :pension)
      expect(policy).to be_pension
    end
  end

  describe "#latest_snapshot" do
    let(:policy) { create(:policy) }

    it "returns the most recent snapshot" do
      create(:policy_snapshot, policy: policy, snapshot_date: 1.month.ago)
      recent = create(:policy_snapshot, policy: policy, snapshot_date: Date.current)

      expect(policy.latest_snapshot).to eq(recent)
    end
  end
end
