# frozen_string_literal: true

class CreatePolicySnapshots < ActiveRecord::Migration[8.1]
  def change
    create_table :policy_snapshots do |t|
      t.references :policy, null: false, foreign_key: true
      t.date :snapshot_date, null: false
      t.decimal :total_value, precision: 12, scale: 2
      t.decimal :total_contributed, precision: 12, scale: 2
      t.decimal :total_delta, precision: 12, scale: 2
      t.decimal :monthly_change, precision: 12, scale: 2

      t.timestamps
    end

    add_index :policy_snapshots, %i[policy_id snapshot_date], unique: true
    add_index :policy_snapshots, :snapshot_date
  end
end
