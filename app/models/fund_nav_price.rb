# frozen_string_literal: true

class FundNavPrice < ApplicationRecord
  belongs_to :fund

  validates :price_date, presence: true, uniqueness: { scope: :fund_id }
  validates :nav, presence: true, numericality: { greater_than: 0 }
  validates :previous_close, numericality: { greater_than: 0 }, allow_nil: true

  scope :chronological, -> { order(:price_date) }
  scope :reverse_chronological, -> { order(price_date: :desc) }
  scope :for_period, ->(start_date, end_date) { where(price_date: start_date..end_date) }

  def daily_change
    return nil unless previous_close

    nav - previous_close
  end

  def daily_change_pct
    return nil unless previous_close&.positive?

    ((nav - previous_close) / previous_close * 100).round(2)
  end
end
