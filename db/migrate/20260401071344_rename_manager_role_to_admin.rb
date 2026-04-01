class RenameManagerRoleToAdmin < ActiveRecord::Migration[8.0]
  def up
    execute "UPDATE users SET role = 'admin' WHERE role = 'manager'"
  end

  def down
    execute "UPDATE users SET role = 'manager' WHERE role = 'admin'"
  end
end
