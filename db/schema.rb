# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140718203330) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"
  enable_extension "hstore"

  create_table "metrics", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.text     "name",                        null: false
    t.text     "description",                 null: false
    t.integer  "order"
    t.boolean  "active",      default: true,  null: false
    t.boolean  "required",    default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "metrics", ["active", "required", "order"], name: "index_metrics_on_active_and_required_and_order", using: :btree

  create_table "submission_metrics", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.uuid     "submission_id"
    t.uuid     "metric_id"
    t.integer  "rating"
    t.text     "comments"
    t.boolean  "completed",       default: false, null: false
    t.datetime "completed_at"
    t.boolean  "comments_public", default: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "submission_metrics", ["metric_id", "created_at"], name: "index_submission_metric_metric_created", using: :btree
  add_index "submission_metrics", ["metric_id", "updated_at"], name: "index_submission_metrics_on_metric_id_and_updated_at", using: :btree
  add_index "submission_metrics", ["submission_id", "created_at"], name: "index_submission_metric_submission__created", using: :btree
  add_index "submission_metrics", ["submission_id", "metric_id", "created_at"], name: "index_submission_metric_submission_metric_created", using: :btree
  add_index "submission_metrics", ["submission_id", "metric_id"], name: "index_submission_metrics_on_submission_id_and_metric_id", using: :btree
  add_index "submission_metrics", ["updated_at"], name: "index_submission_metrics_on_updated_at", using: :btree

  create_table "submission_reminder_templates", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.date     "submissions_start_date",                 null: false
    t.date     "submissions_end_date",                   null: false
    t.datetime "reify_at"
    t.boolean  "reified",                default: false, null: false
    t.text     "medium",                                 null: false
    t.text     "template",                               null: false
    t.hstore   "meta"
  end

  add_index "submission_reminder_templates", ["reified", "reify_at"], name: "index_submission_reminder_templates_on_reified_and_reify_at", using: :btree

  create_table "submission_reminders", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.uuid     "submission_id",                                   null: false
    t.text     "medium",                                          null: false
    t.text     "message"
    t.hstore   "meta"
    t.boolean  "sent",                            default: false, null: false
    t.datetime "sent_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.uuid     "submission_reminder_template_id"
  end

  add_index "submission_reminders", ["created_at", "sent"], name: "index_submission_reminders_on_created_at_and_sent", using: :btree
  add_index "submission_reminders", ["sent"], name: "index_submission_reminders_on_sent", using: :btree
  add_index "submission_reminders", ["submission_id"], name: "index_submission_reminders_on_submission_id", using: :btree

  create_table "submissions", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.uuid     "user_id"
    t.boolean  "completed",                   default: false, null: false
    t.datetime "completed_at"
    t.string   "comments",        limit: 140
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "comments_public",             default: true
    t.boolean  "opted_out",                   default: false, null: false
  end

  add_index "submissions", ["created_at"], name: "index_submissions_on_created_at", using: :btree
  add_index "submissions", ["updated_at"], name: "index_submissions_on_updated_at", using: :btree
  add_index "submissions", ["user_id"], name: "index_submissions_on_user_id", using: :btree

  create_table "teams", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.text     "name",                           null: false
    t.text     "slug",                           null: false
    t.uuid     "parent_team_id"
    t.uuid     "manager_user_id"
    t.text     "description"
    t.boolean  "active",          default: true, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "teams", ["manager_user_id"], name: "index_teams_on_manager_user_id", using: :btree
  add_index "teams", ["parent_team_id"], name: "index_teams_on_parent_team_id", using: :btree
  add_index "teams", ["slug"], name: "index_teams_on_slug", using: :btree

  create_table "teams_users", id: false, force: true do |t|
    t.uuid "team_id"
    t.uuid "user_id"
  end

  add_index "teams_users", ["team_id"], name: "index_teams_users_on_team_id", using: :btree
  add_index "teams_users", ["user_id"], name: "index_teams_users_on_user_id", using: :btree

  create_table "users", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.text     "name"
    t.text     "email",                           null: false
    t.uuid     "manager_user_id"
    t.text     "manager_email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "admin",           default: false, null: false
    t.boolean  "active",          default: true,  null: false
  end

  add_index "users", ["active"], name: "index_users_on_active", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["manager_user_id"], name: "index_users_on_manager_user_id", using: :btree

  add_foreign_key "submission_metrics", "metrics", name: "submission_metrics_metric_id_fk"
  add_foreign_key "submission_metrics", "submissions", name: "submission_metrics_submission_id_fk"

  add_foreign_key "submission_reminders", "submission_reminder_templates", name: "submission_reminders_submission_reminder_template_id_fk"

  add_foreign_key "submissions", "users", name: "submissions_user_id_fk"

  add_foreign_key "teams", "teams", name: "teams_parent_team_id_fk", column: "parent_team_id"
  add_foreign_key "teams", "users", name: "teams_manager_user_id_fk", column: "manager_user_id"

end
