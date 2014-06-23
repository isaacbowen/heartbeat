class AddTimestampsToSubmissionMetrics < ActiveRecord::Migration
  def change
    change_table :submission_metrics do |t|
      t.timestamps
    end

    add_index :submission_metrics, [:submission_id, :created_at], name: 'index_submission_metric_submission__created'
    add_index :submission_metrics, [:metric_id, :created_at], name: 'index_submission_metric_metric_created'
    add_index :submission_metrics, [:submission_id, :metric_id, :created_at], name: 'index_submission_metric_submission_metric_created'

    reversible do |dir|
      dir.up do
        SubmissionMetric.all.each do |sm|
          sm.update_column :created_at, sm.submission.created_at
          sm.update_column :updated_at, sm.submission.updated_at
        end
      end
    end
  end
end
