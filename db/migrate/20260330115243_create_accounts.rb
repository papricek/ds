class CreateAccounts < ActiveRecord::Migration[8.0]
  def change
    create_table :accounts do |t|
      t.string :name, null: false
      t.string :subdomain
      t.jsonb :settings, default: {}
      t.string :plan, default: "light", null: false
      t.timestamps
    end
    add_index :accounts, :subdomain, unique: true
  end
end
