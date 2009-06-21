class CreateRevisionBridges < ActiveRecord::Migration
  def self.up
    create_table :revision_bridges do |t|
      t.integer :parent_id, :child_id
      t.timestamps
    end
  end

  def self.down
    drop_table :revision_bridges
  end
end
