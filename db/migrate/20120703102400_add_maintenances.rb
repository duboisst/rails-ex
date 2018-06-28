class AddMaintenances < ActiveRecord::Migration[4.2]
  def self.up
    create_table :maintenances do |t|
      t.integer :is_in_maintenance => 1
      t.text :reason
      t.datetime :created_at
      t.datetime :updated_at
      t.text :flash_message
      t.string :flash_message_color
    end
  end

  def self.down
    drop_table :logs
  end
end
