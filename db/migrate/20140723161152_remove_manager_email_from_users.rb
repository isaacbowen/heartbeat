class RemoveManagerEmailFromUsers < ActiveRecord::Migration
  def up
    remove_index :users, :manager_email
    remove_column :users, :manager_email
  end

  def down
    add_column :users, :manager_email, :text
    add_index :users, :manager_email
  end
end
