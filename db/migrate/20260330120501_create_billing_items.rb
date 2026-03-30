class CreateBillingItems < ActiveRecord::Migration[8.0]
  def change
    create_table :billing_items do |t|
      t.references :billing, null: false, foreign_key: true
      t.references :sharing, foreign_key: true
      t.string :kind, default: "sharings", null: false
      t.string :transaction_type, null: false
      t.decimal :amount, precision: 12, scale: 4, default: 0
      t.decimal :price, precision: 12, scale: 2, default: 0
      t.string :name
      t.timestamps
    end
  end
end
