class CreateGroups < ActiveRecord::Migration[8.0]
  def change
    create_table :groups do |t|
      t.references :account, null: false, foreign_key: true
      t.string :name, null: false
      t.string :identifier
      t.timestamps
    end
  end
end
