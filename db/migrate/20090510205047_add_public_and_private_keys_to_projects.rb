class AddPublicAndPrivateKeysToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :public_key, :string
    add_column :projects, :private_key, :string
  end

  def self.down
    remove_column :projects, :private_key
    remove_column :projects, :public_key
  end
end
