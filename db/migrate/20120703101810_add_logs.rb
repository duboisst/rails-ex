class AddLogs < ActiveRecord::Migration[4.2]
  def self.up
    create_table :logs do |t|
      t.integer :user_id
      t.string :action, :limit => 10
      t.string :params
      t.datetime :created_at
      t.datetime :updated_at
    end
  end

  def self.down
    drop_table :logs
  end
end
