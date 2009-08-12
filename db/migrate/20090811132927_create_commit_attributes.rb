class CreateCommitAttributes < ActiveRecord::Migration
  def self.up
    create_table :commit_attributes do |t|
      t.string :name
      t.text :value
      t.integer :commit_id
      t.timestamps
    end
  end

  def self.down
    drop_table :commit_attributes
  end
end
