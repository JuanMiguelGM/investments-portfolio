# frozen_string_literal: true

# Example funds — replace with your own funds, ISINs, and Yahoo Finance tickers.
# For funds not available on Yahoo Finance (e.g. pension plans), set yahoo_ticker to nil.
funds_data = [
  { name: "Example Equity Fund A", isin: "XX0000000001", yahoo_ticker: "XX0000000001.XX", allocation_pct: 60 },
  { name: "Example Bond Fund B",   isin: "XX0000000002", yahoo_ticker: "XX0000000002.XX", allocation_pct: 40 }
]

funds_data.each do |attrs|
  Fund.find_or_create_by!(isin: attrs[:isin]) do |fund|
    fund.assign_attributes(attrs)
  end
end

# Example pension fund — NAV entered manually via /admin/nav_entries/new
Fund.find_or_create_by!(isin: "XX0000000099") do |fund|
  fund.assign_attributes(
    name: "Example Pension Fund",
    isin: "XX0000000099",
    yahoo_ticker: nil,
    allocation_pct: 0
  )
end

# Example policies — rename to match your actual products
policies_data = [
  { name: "Insurance Policy 1", slug: "policy-1", inception_date: Date.new(2019, 1, 1), policy_type: :insurance },
  { name: "Insurance Policy 2", slug: "policy-2", inception_date: Date.new(2020, 1, 1), policy_type: :insurance },
  { name: "Pension Plan",       slug: "pp",        inception_date: Date.new(2019, 1, 1), policy_type: :pension  }
]

policies_data.each do |attrs|
  policy = Policy.find_or_create_by!(slug: attrs[:slug]) do |p|
    p.assign_attributes(attrs)
  end
  policy.update!(policy_type: attrs[:policy_type])
end

puts "Seeded #{Fund.count} funds and #{Policy.count} policies" # rubocop:disable Rails/Output
