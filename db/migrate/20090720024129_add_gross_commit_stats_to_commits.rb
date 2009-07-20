class AddGrossCommitStatsToCommits < ActiveRecord::Migration
  def self.up
    add_column :commits, :line_additions, :integer
    add_column :commits, :line_deletions, :integer
    add_column :commits, :line_total, :integer
    add_column :commits, :affected_file_count, :integer
  end

  def self.down
    remove_column :commits, :affected_file_count
    remove_column :commits, :line_total
    remove_column :commits, :line_deletions
    remove_column :commits, :line_additions
  end
end
