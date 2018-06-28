class CreateProfilesChannels < ActiveRecord::Migration[4.2]
  def self.up
    create_table :channels_profiles, :id => false, :force => true do |t|
      t.string :profile_id
      t.string :channel_id

      t.timestamps
    end
  end

  def self.down
    drop_table :channels_profiles
  end
end
