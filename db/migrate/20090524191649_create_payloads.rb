class CreatePayloads < ActiveRecord::Migration
  def self.up
    create_table :payloads do |t|
      t.text :content
      t.integer :project_id
      t.timestamps
    end
  end

  def self.down
    drop_table :payloads
  end
end
