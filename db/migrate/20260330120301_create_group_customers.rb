class CreateGroupCustomers < ActiveRecord::Migration[8.0]
  def change
    create_table :group_customers do |t|
      t.references :group, null: false, foreign_key: true
      t.string :ean, null: false
      t.date :valid_from
      t.date :valid_to
      t.timestamps
    end
    add_index :group_customers, [ :group_id, :ean ], unique: true
  end
end
