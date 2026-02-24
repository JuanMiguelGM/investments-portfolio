# frozen_string_literal: true

FactoryBot.define do
  factory :policy do
    sequence(:name) { |n| "Policy #{n}" }
    sequence(:slug) { |n| "policy-#{n}" }
    inception_date { Date.new(2019, 3, 1) }
    active { true }
  end
end
