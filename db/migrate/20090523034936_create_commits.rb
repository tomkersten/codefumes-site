class CreateCommits < ActiveRecord::Migration
  def self.up
    create_table :commits do |t|
      t.string :identifier, :author_name, :author_email, :committer_name, :committer_email
      t.string :short_message, :message, :committed_at, :authored_at
      t.timestamps
    end
  end

  def self.down
    drop_table :commits
  end
end
