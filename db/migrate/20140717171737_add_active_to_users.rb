class AddActiveToUsers < ActiveRecord::Migration
  def change
    add_column :users, :active, :boolean, default: true, null: false
    add_index :users, :active
  end
end
