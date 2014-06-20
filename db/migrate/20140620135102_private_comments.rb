class PrivateComments < ActiveRecord::Migration
  def change
    add_column :submission_metrics, :comments_public, :boolean, default: true
    add_column :submissions, :comments_public, :boolean, default: true
  end
end
