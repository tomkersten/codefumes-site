class AddPlanIdToSubscriptions < ActiveRecord::Migration
  def self.up
    add_column :subscriptions, :plan_id, :integer
  end

  def self.down
    remove_column :subscriptions, :plan_id
  end
end
