class CreateSharings < ActiveRecord::Migration[8.0]
  def change
    create_table :sharings do |t|
      t.references :account, null: false, foreign_key: true
      t.references :from_address, null: false, foreign_key: { to_table: :addresses }
      t.references :to_address, null: false, foreign_key: { to_table: :addresses }
      t.string :from_ean, null: false
      t.string :to_ean, null: false
      t.string :status, default: "active", null: false
      t.decimal :fixed_price, precision: 10, scale: 4
      t.timestamps
    end
    add_index :sharings, [:from_ean, :to_ean, :account_id], unique: true
  end
end
