class CreateEdcReadings < ActiveRecord::Migration[8.0]
  def change
    create_table :edc_readings do |t|
      t.string :ean, null: false
      t.decimal :original, precision: 12, scale: 4
      t.decimal :final, precision: 12, scale: 4
      t.datetime :shared_at, null: false
      t.timestamps
    end
    add_index :edc_readings, [ :ean, :shared_at ], unique: true
    add_index :edc_readings, :ean
    add_index :edc_readings, :shared_at
  end
end
