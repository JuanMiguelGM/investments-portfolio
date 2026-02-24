# frozen_string_literal: true

class CreateFundNavPrices < ActiveRecord::Migration[8.1]
  def change
    create_table :fund_nav_prices do |t|
      t.references :fund, null: false, foreign_key: true
      t.date :price_date, null: false
      t.decimal :nav, precision: 12, scale: 4, null: false
      t.decimal :previous_close, precision: 12, scale: 4

      t.timestamps
    end

    add_index :fund_nav_prices, %i[fund_id price_date], unique: true
    add_index :fund_nav_prices, :price_date
  end
end
