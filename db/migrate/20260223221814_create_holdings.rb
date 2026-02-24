# frozen_string_literal: true

class CreateHoldings < ActiveRecord::Migration[8.1]
  def change
    create_table :holdings do |t|
      t.references :fund, null: false, foreign_key: true
      t.references :policy, null: false, foreign_key: true
      t.decimal :units, precision: 15, scale: 6, null: false, default: 0
      t.date :units_as_of_date

      t.timestamps
    end

    add_index :holdings, %i[fund_id policy_id], unique: true
  end
end
