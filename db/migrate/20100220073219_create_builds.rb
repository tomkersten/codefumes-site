class CreateBuilds < ActiveRecord::Migration
  def self.up
    create_table :builds do |t|
      t.integer :commit_id
      t.string :name, :state
      t.datetime :started_at, :ended_at
      t.timestamps
    end
  end

  def self.down
    drop_table :builds
  end
end
