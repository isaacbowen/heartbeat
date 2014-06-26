class CreateSubmissionReminders < ActiveRecord::Migration
  def change
    create_table :submission_reminders, id: :uuid do |t|
      t.uuid :submission_id, null: false

      t.text :medium, null: false
      t.text :message
      t.hstore :meta

      t.boolean :sent, default: false, null: false
      t.timestamp :sent_at

      t.timestamps
    end

    add_index :submission_reminders, :submission_id
    add_index :submission_reminders, [:created_at, :sent]
    add_index :submission_reminders, :sent
  end
end
