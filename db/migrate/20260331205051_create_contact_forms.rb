class CreateContactForms < ActiveRecord::Migration[8.0]
  def change
    create_table :contact_forms do |t|
      t.string :name
      t.string :email
      t.string :phone
      t.text :message

      t.timestamps
    end
  end
end
