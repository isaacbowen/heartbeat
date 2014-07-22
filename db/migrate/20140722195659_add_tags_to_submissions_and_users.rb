class AddTagsToSubmissionsAndUsers < ActiveRecord::Migration
  def change
    add_column :submissions, :tags, :string, array: true, default: '{}'
    add_index  :submissions, :tags, using: 'gin'

    add_column :users, :tags, :string, array: true, default: '{}'
    add_index  :users, :tags, using: 'gin'
  end
end
