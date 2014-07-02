class CreateSubmissionReminderTemplates < ActiveRecord::Migration
  def change
    create_table :submission_reminder_templates, id: :uuid do |t|
      t.date :submissions_start_date, null: false
      t.date :submissions_end_date, null: false

      t.timestamp :reify_at
      t.boolean :reified, null: false, default: false

      t.text :medium, null: false
      t.text :template, null: false
      t.hstore :meta
    end

    change_table :submission_reminders do |t|
      t.uuid :submission_reminder_template_id
      t.foreign_key :submission_reminder_templates
    end

    add_index :submission_reminder_templates, [:reified, :reify_at]
  end
end
