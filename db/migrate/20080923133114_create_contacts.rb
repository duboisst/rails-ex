class CreateContacts < ActiveRecord::Migration[4.2]
  def self.up
    create_table :contacts do |t|
      t.string :name
      t.string :tel
      t.text :address
      t.text :info

      t.timestamps
    end
  end

  def self.down
    drop_table :contacts
  end
end
