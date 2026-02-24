# frozen_string_literal: true

class Holding < ApplicationRecord
  belongs_to :fund
  belongs_to :policy

  validates :units, numericality: { greater_than_or_equal_to: 0 }
  validates :fund_id, uniqueness: { scope: :policy_id }

  scope :with_units, -> { where("units > 0") }

  def current_value
    return 0 unless units.positive? && fund.latest_nav_value

    units * fund.latest_nav_value
  end
end
