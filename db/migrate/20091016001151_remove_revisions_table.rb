class RemoveRevisionsTable < ActiveRecord::Migration
  def self.up
    drop_table :revisions
  end

  def self.down
    create_table :revisions do |t|
      t.integer :project_id, :commit_id
      t.timestamps
    end
  end
end
