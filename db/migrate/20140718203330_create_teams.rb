class CreateTeams < ActiveRecord::Migration
  def change
    create_table :teams, id: :uuid do |t|
      t.text :name, null: false
      t.text :slug, null: false
      t.uuid :manager_user_id
      t.foreign_key :users, column: :manager_user_id
      t.text :description
      t.boolean :private, null: false, default: false

      t.timestamps
    end

    add_index :teams, :slug
    add_index :teams, :manager_user_id
    add_index :teams, :private

    create_table :teams_users, id: false do |t|
      t.uuid :team_id
      t.foreign_key :teams
      t.uuid :user_id
      t.foreign_key :users
    end

    add_index :teams_users, :team_id
    add_index :teams_users, :user_id

    reversible do |direction|
      direction.up do
        managers = User.where(email: User.uniq(:manager_email).pluck(:manager_email))

        managers.each do |manager|
          Team.create!(
            manager: manager,
            name: "#{manager.abbreviated_name}'s Team",
            users: User.where(manager_email: manager.email),
            private: true,
          )
        end
      end
    end
  end
end
