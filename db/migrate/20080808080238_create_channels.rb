class CreateChannels < ActiveRecord::Migration[4.2]
  def self.up
    create_table :channels do |t|
      t.string :code
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :channels
  end
end
