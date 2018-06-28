class CreateProfiles < ActiveRecord::Migration[4.2]
  def self.up
    create_table :profiles do |t|
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :profiles
  end
end
