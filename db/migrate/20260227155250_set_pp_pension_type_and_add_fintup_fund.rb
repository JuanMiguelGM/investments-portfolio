# frozen_string_literal: true

# One-time data migration — no-op for fresh installs.
# Seeds handle the initial policy_type and fund setup.
class SetPpPensionTypeAndAddFintupFund < ActiveRecord::Migration[8.1]
  def up; end

  def down; end
end
