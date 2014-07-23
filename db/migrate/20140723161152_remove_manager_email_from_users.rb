class RemoveManagerEmailFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :manager_email
  end

  def down
    add_column :users, :manager_email, :text
  end
end
