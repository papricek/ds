class CreateAddresses < ActiveRecord::Migration[8.0]
  def change
    create_table :addresses do |t|
      t.references :user, null: false, foreign_key: true
      t.references :account, null: false, foreign_key: true
      t.string :ean, null: false
      t.string :role, null: false
      t.string :street
      t.string :city
      t.string :zip
      t.string :label
      t.timestamps
    end
    add_index :addresses, [:ean, :account_id], unique: true
  end
end
