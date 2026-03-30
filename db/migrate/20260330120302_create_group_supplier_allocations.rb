class CreateGroupSupplierAllocations < ActiveRecord::Migration[8.0]
  def change
    create_table :group_supplier_allocations do |t|
      t.references :group_customer, null: false, foreign_key: true
      t.string :ean, null: false
      t.decimal :allocation_ratio, precision: 5, scale: 4, default: 1.0
      t.integer :allocation_order, default: 1
      t.timestamps
    end
  end
end
