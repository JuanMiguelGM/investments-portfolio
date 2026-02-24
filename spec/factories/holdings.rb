# frozen_string_literal: true

FactoryBot.define do
  factory :holding do
    fund
    policy
    units { 100.0 }
    units_as_of_date { Date.current }
  end
end
