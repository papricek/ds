class CreateUserTokens < ActiveRecord::Migration[8.0]
  def change
    create_table :user_tokens do |t|
      t.references :user, null: false, foreign_key: true
      t.string :token, null: false
      t.integer :kind, null: false
      t.datetime :issued_at, null: false
      t.datetime :expires_at, null: false
      t.timestamps
    end
    add_index :user_tokens, :token, unique: true
  end
end
