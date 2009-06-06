class ChangeCommittedAtAndAuthoredAtToDatetime < ActiveRecord::Migration
  def self.up
    change_column :commits, :committed_at, :datetime
    change_column :commits, :authored_at, :datetime
  end

  def self.down
    change_column :commits, :authored_at, :string
    change_column :commits, :committed_at, :string
  end
end
