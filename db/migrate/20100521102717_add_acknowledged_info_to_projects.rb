class AddAcknowledgedInfoToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :acknowledged_at, :datetime
  end

  def self.down
    remove_column :projects, :acknowledged_at
  end
end
