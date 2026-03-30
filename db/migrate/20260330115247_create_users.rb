class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.references :account, null: false, foreign_key: true
      t.string :name, null: false
      t.string :email, null: false
      t.string :phone
      t.string :password_digest, null: false
      t.string :role, default: "user", null: false
      t.boolean :confirmed, default: true, null: false
      t.timestamps
    end
    add_index :users, :email, unique: true
  end
end
