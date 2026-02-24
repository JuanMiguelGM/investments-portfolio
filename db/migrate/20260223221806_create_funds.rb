# frozen_string_literal: true

class CreateFunds < ActiveRecord::Migration[8.1]
  def change
    create_table :funds do |t|
      t.string :name, null: false
      t.string :isin, null: false
      t.string :yahoo_ticker, null: false
      t.decimal :allocation_pct, precision: 5, scale: 2, default: 0

      t.timestamps
    end

    add_index :funds, :isin, unique: true
  end
end
