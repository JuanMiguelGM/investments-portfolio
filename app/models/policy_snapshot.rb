# frozen_string_literal: true

class PolicySnapshot < ApplicationRecord
  belongs_to :policy

  validates :snapshot_date, presence: true, uniqueness: { scope: :policy_id }
  validates :total_value, presence: true

  scope :chronological, -> { order(:snapshot_date) }
  scope :reverse_chronological, -> { order(snapshot_date: :desc) }
  scope :for_period, ->(start_date, end_date) { where(snapshot_date: start_date..end_date) }

  def gain_pct
    return nil unless total_contributed&.positive?

    ((total_delta / total_contributed) * 100).round(2)
  end
end
