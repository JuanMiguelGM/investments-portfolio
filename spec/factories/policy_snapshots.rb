# frozen_string_literal: true

FactoryBot.define do
  factory :policy_snapshot do
    policy
    snapshot_date { Date.current }
    total_value { 10_000.00 }
    total_contributed { 9_000.00 }
    total_delta { 1_000.00 }
    monthly_change { 200.00 }
  end
end
