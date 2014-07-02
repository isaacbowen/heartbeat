class CreateSubmissionReminderTemplates < ActiveRecord::Migration
  def change
    create_table :submission_reminder_templates, id: :uuid do |t|
      t.date :submissions_start_date, null: false
      t.date :submissions_end_date, null: false

      t.timestamp :send_at
      t.boolean :sent, null: false, default: false

      t.text :medium, null: false
      t.text :template, null: false
      t.hstore :meta
    end

    change_table :submission_reminders do |t|
      t.uuid :submission_reminder_template_id
      t.foreign_key :submission_reminder_templates
    end

    add_index :submission_reminder_templates, [:sent, :send_at]
  end
end
