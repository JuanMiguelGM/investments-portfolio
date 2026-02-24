# frozen_string_literal: true

class AddPolicyTypeAndOptionalYahooTicker < ActiveRecord::Migration[8.1]
  def change
    change_column_null :funds, :yahoo_ticker, true
    add_column :policies, :policy_type, :integer, default: 0, null: false
  end
end
