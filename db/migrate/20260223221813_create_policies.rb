# frozen_string_literal: true

class CreatePolicies < ActiveRecord::Migration[8.1]
  def change
    create_table :policies do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.date :inception_date, null: false
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :policies, :slug, unique: true
  end
end
