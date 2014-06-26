class AddUpdatedAtIndexesForSubThings < ActiveRecord::Migration
  def change
    add_index :submissions, :updated_at
    add_index :submission_metrics, :updated_at
    add_index :submission_metrics, [:metric_id, :updated_at]
  end
end
