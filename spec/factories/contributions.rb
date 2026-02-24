# frozen_string_literal: true

FactoryBot.define do
  factory :contribution do
    policy
    contribution_date { Date.current }
    amount { 500.00 }
  end
end
