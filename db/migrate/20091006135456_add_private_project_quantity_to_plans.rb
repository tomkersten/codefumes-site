class AddPrivateProjectQuantityToPlans < ActiveRecord::Migration
  def self.up
    add_column :plans, :private_project_qty, :integer
  end

  def self.down
    remove_column :plans, :private_project_qty
  end
end
