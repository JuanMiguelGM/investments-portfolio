# frozen_string_literal: true

class Fund < ApplicationRecord
  has_many :holdings, dependent: :destroy
  has_many :policies, through: :holdings
  has_many :fund_nav_prices, dependent: :destroy

  validates :name, presence: true
  validates :isin, presence: true, uniqueness: true
  validates :allocation_pct, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }

  scope :ordered, -> { order(:name) }
  scope :auto_fetch, -> { where.not(yahoo_ticker: [nil, ""]) }

  def latest_nav
    fund_nav_prices.order(price_date: :desc).first
  end

  def latest_nav_value
    latest_nav&.nav
  end
end
