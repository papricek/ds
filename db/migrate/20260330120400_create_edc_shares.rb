class CreateEdcShares < ActiveRecord::Migration[8.0]
  def change
    create_table :edc_shares do |t|
      t.string :from_ean, null: false
      t.string :to_ean, null: false
      t.decimal :value, precision: 12, scale: 4, null: false
      t.datetime :shared_at, null: false
      t.timestamps
    end
    add_index :edc_shares, [ :from_ean, :to_ean, :shared_at ], unique: true
    add_index :edc_shares, :from_ean
    add_index :edc_shares, :to_ean
    add_index :edc_shares, :shared_at
  end
end
