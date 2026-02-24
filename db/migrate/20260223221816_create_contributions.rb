# frozen_string_literal: true

class CreateContributions < ActiveRecord::Migration[8.1]
  def change
    create_table :contributions do |t|
      t.references :policy, null: false, foreign_key: true
      t.date :contribution_date, null: false
      t.decimal :amount, precision: 10, scale: 2, null: false

      t.timestamps
    end

    add_index :contributions, %i[policy_id contribution_date]
  end
end
