# frozen_string_literal: true

class Contribution < ApplicationRecord
  belongs_to :policy

  validates :contribution_date, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }

  scope :chronological, -> { order(:contribution_date) }
  scope :reverse_chronological, -> { order(contribution_date: :desc) }
end
