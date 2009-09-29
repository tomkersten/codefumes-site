class AddVisibilityToProject < ActiveRecord::Migration
  def self.up
    add_column :projects, :visibility, :string, :default => 'public'
  end

  def self.down
    remove_column :projects, :visibility
  end
end
