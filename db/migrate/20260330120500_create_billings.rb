class CreateBillings < ActiveRecord::Migration[8.0]
  def change
    create_table :billings do |t|
      t.references :account, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :kind, default: "receipt", null: false
      t.string :status, default: "active", null: false
      t.string :period, default: "monthly", null: false
      t.date :start_at, null: false
      t.date :end_at, null: false
      t.date :issue_date
      t.date :supply_date
      t.date :due_date
      t.string :variable_symbol
      t.timestamps
    end
    add_index :billings, [:account_id, :user_id]
    add_index :billings, :variable_symbol
  end
end
