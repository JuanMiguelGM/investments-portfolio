# frozen_string_literal: true

FactoryBot.define do
  factory :fund_nav_price do
    fund
    price_date { Date.current }
    nav { 150.00 }
    previous_close { 149.50 }
  end
end
