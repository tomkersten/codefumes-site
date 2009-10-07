class AddStateToSubscriptions < ActiveRecord::Migration
  def self.up
    add_column :subscriptions, :state, :string
  end

  def self.down
    remove_column :subscriptions, :state
  end
end
