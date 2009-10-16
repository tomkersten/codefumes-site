class AddProjectIdToCommits < ActiveRecord::Migration
  def self.up
    add_column :commits, :project_id, :integer
  end

  def self.down
    remove_column :commits, :project_id
  end
end
