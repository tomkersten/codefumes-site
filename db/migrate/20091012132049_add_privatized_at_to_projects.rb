class AddPrivatizedAtToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :privatized_at, :datetime, :default => nil
  end

  def self.down
    remove_column :privatized_at, :datetime
  end
end
