# frozen_string_literal: true

class Policy < ApplicationRecord
  has_many :holdings, dependent: :destroy
  has_many :funds, through: :holdings
  has_many :contributions, dependent: :destroy
  has_many :policy_snapshots, dependent: :destroy

  enum :policy_type, { insurance: 0, pension: 1 }

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :inception_date, presence: true

  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(:name) }

  def to_param
    slug
  end

  def total_contributed
    contributions.sum(:amount)
  end

  def latest_snapshot
    policy_snapshots.order(snapshot_date: :desc).first
  end
end
