# frozen_string_literal: true

FactoryBot.define do
  factory :fund do
    sequence(:name) { |n| "Fund #{n}" }
    sequence(:isin) { |n| "IE00000000#{n.to_s.rjust(2, "0")}" }
    sequence(:yahoo_ticker) { |n| "IE00000000#{n.to_s.rjust(2, "0")}.IR" }
    allocation_pct { 10 }
  end
end
